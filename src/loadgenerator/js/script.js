import http from 'k6/http';
import { sleep, fail } from 'k6';
import { Counter } from 'k6/metrics';

// TODO: Make this pull products from API instead of hardcoding
const productData = [
  '6d62d909-f957-430e-8689-b5129c0bb75e',
  'a0a4f044-b040-410d-8ead-4de0446aec7e',
  '808a2de1-1aaa-4c25-a9b9-6612e8f29a38',
  '510a0d7e-8e83-4193-b483-e27e09ddc34d',
  'ee3715be-b4ba-11ea-b3de-0242ac130004',
  'f4ebd070-b4ba-11ea-b3de-0242ac130004'
]

let baseUrl = __ENV.WATCHN_BASE_URL

if(!baseUrl) {
  console.log("Error: WATCHN_BASE_URL must be set")
  fail(1)
}

let region = __ENV.WATCHN_REGION

if(!region) {
  region = "default"
}

let target = __ENV.WATCHN_TARGET

if(!target) {
  target = 20
}
else {
  target = parseInt(target)
}

let duration = __ENV.WATCHN_DURATION

if(!duration) {
  duration = 20
}
else {
  duration = parseInt(duration)
}

let fetch = __ENV.WATCHN_FETCH

if(!fetch) {
  fetch = "true"
}

export let http_req_status_2xx = new Counter("http_req_status_2xx");
export let http_req_status_3xx = new Counter("http_req_status_3xx");
export let http_req_status_4xx = new Counter("http_req_status_4xx");
export let http_req_status_5xx = new Counter("http_req_status_5xx");

export let options = {
  tags: {
    region: __ENV.WATCHN_REGION
  },
  stages: [
    { duration: "2s", target: target },  // Ramp
    { duration: `${duration}m`, target: target }, // Work
    { duration: "2s", target: 0 },   // Down
  ],
  concurrentResourceLoading: true,
  fetchResources: fetch == 'true' ? true : false
}

export default function () {
  let numProducts = Math.ceil(Math.random() * 10)

  let products = Array.from({length: numProducts}, () => productData[Math.floor(Math.random() * productData.length)]);

  let home = http.get(`${baseUrl}/home`);
  recordStatusMetric(home);

  getResources(home);

  sleep(1);

  let product;
  let addToCart;

  // For now only buy 1 item on each iteration
  var itemId = products[Math.floor(Math.random() * products.length)];

  products.forEach((productId) => {
    product = http.get(`${baseUrl}/catalog/${productId}`);
    recordStatusMetric(product);

    if (productId == itemId) {
      addToCart = product.submitForm({
        formSelector: 'form#addToCart',
        fields: { 
          productId: productId
        },
      });
      recordStatusMetric(addToCart);
    }

    sleep(1);
  });

  let cart = http.get(`${baseUrl}/cart`);
  recordStatusMetric(cart);

  sleep(1);

  let checkout = http.get(`${baseUrl}/checkout`);
  recordStatusMetric(checkout);

  let delivery = checkout.submitForm({
    formSelector: 'form#checkoutForm',
    fields: { 
      firstName: 'John', 
      lastName: 'Doe',
      email: 'john@example.com',
      address1: '12345 Main St.',
      address2: '#123',
      city: 'New York',
      state: 'CA',
      zip: '12345'
    },
  });
  recordStatusMetric(delivery);

  let payment = delivery.submitForm({
    formSelector: 'form#checkoutForm',
    fields: { 
      token: 'priority-mail'
    },
  });
  recordStatusMetric(payment);

  let review = payment.submitForm({
    formSelector: 'form#checkoutForm',
    fields: { 
      ccName: 'John Doe',
      ccNumber: '1234567890',
      ccExpiration: '12/25',
      ccCvv: '123'
    },
  });
  recordStatusMetric(review);

  let order = review.submitForm({
    formSelector: 'form#checkoutForm'
  });
  recordStatusMetric(order);
};

function recordStatusMetric(response) {
  if(response.status >= 500) {
    http_req_status_5xx.add(1);
  }
  else if(response.status >= 400) {
    http_req_status_4xx.add(1);
  }
  else if(response.status >= 300) {
    http_req_status_3xx.add(1);
  }
  else {
    http_req_status_2xx.add(1);
  }
}

function getResources(response) {
  if(!options.fetchResources) {
    return;
  }

  const resources = [];
  response
    .html()
    .find('*[href]:not(a)')
    .each((index, element) => {
      if(!element.attributes().href.value.startsWith('data')) {
        resources.push(element.attributes().href.value);
      }
    });
  response
    .html()
    .find('*[src]:not(a)')
    .each((index, element) => {
      resources.push(element.attributes().src.value);
    });

  if (options.concurrentResourceLoading) {
    const responses = http.batch(
      resources.map((r) => {
        return ['GET', resolveUrl(r, response.url), null];
      })
    );
    responses.forEach((response) => {
      recordStatusMetric(response);
    });
  } else {
    resources.forEach((r) => {
      const res = http.get(resolveUrl(r, response.url));
      recordStatusMetric(res);
    });
  }
}

function resolveUrl(path, url) {
  if(path.charAt(0) != '/') {
    return path;
  }

  var parts = url.split( '/' );
  var pos = url.lastIndexOf(parts[parts.length - 1]);
  var origin = url.slice(0, pos-1);

  return origin+path;
}