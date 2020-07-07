import http from 'k6/http';
import { sleep } from 'k6';

// TODO: Make this pull products from API instead of hardcoding
const productData = [
  "6d62d909-f957-430e-8689-b5129c0bb75e",
  "a0a4f044-b040-410d-8ead-4de0446aec7e",
  "808a2de1-1aaa-4c25-a9b9-6612e8f29a38",
  "510a0d7e-8e83-4193-b483-e27e09ddc34d",
  "ee3715be-b4ba-11ea-b3de-0242ac130004",
  "f4ebd070-b4ba-11ea-b3de-0242ac130004"
]

export let options = {
  tags: {
    region: __ENV.WATCHN_REGION
  },
  stages: [
    { duration: "2m", target: 20 },  // Ramp
    { duration: "10m", target: 20 }, // Work
    { duration: "2m", target: 0 },   // Down
  ]
}

export default function () {
  let numProducts = Math.ceil(Math.random() * 10)

  let products = Array.from({length: numProducts}, () => productData[Math.floor(Math.random() * productData.length)]);

  http.get(`${__ENV.WATCHN_BASE_URL}/home`);

  sleep(1);

  let product;

  products.forEach((product) => {
    product = http.get(`${__ENV.WATCHN_BASE_URL}/catalog/`+product);

    product.submitForm({
      formSelector: 'form#addToCart',
      fields: { 
        productId: product
      },
    });

    sleep(1);
  });

  http.get(`${__ENV.WATCHN_BASE_URL}/cart`);

  sleep(1);

  let checkout = http.get(`${__ENV.WATCHN_BASE_URL}/checkout`);

  checkout.submitForm({
    formSelector: 'form#checkoutForm',
    fields: { 
      firstName: 'John', 
      lastName: 'Doe',
      email: 'john@localhost',
      address: '12345 Main St.',
      address2: '#123',
      country: 'United States',
      state: 'CA',
      zip: '12345',
      ccName: 'John Doe',
      ccNumber: '1234567890',
      ccExpiration: '12/25',
      ccCvv: '123'
    },
  });
};