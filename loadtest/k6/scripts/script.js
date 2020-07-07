import http from 'k6/http';
import { sleep } from 'k6';

const productData = [
  "6d62d909-f957-430e-8689-b5129c0bb75e",
  "a0a4f044-b040-410d-8ead-4de0446aec7e",
  "808a2de1-1aaa-4c25-a9b9-6612e8f29a38",
  "510a0d7e-8e83-4193-b483-e27e09ddc34d",
  "ee3715be-b4ba-11ea-b3de-0242ac130004",
  "f4ebd070-b4ba-11ea-b3de-0242ac130004"
]

export default function () {
  let numProducts = Math.ceil(Math.random() * 10)

  let products = Array.from({length: numProducts}, () => productData[Math.floor(Math.random() * productData.length)]);

  const response = http.get(`${__ENV.WATCHN_BASE_URL}/home`);

  sleep(1);

  products.forEach((product) => {
    const response = http.get(`${__ENV.WATCHN_BASE_URL}/catalog/`+product);

    sleep(1);
  });
};