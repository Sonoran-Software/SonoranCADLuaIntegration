# REST Methods & Usage
The following methods can be accessed from the `rest` property of an CAD Manager & CMS Manager.

## Basic General Usage
```js
const Sonoran = require('sonoran.js');
const instance = Sonoran.instance({
  communityId: 'mycommunity',
  apiKey: 'e6ba9d68-ca7a-4e59-a9e2-93e275b4e0bf',
  product: Sonoran.productEnums.CMS
});

try {
  const subVersion = await instance.cms.rest.request('GET_SUB_VERSION');
  console.log(`Community version is: ${subVersion}`);
} catch (err) {
  console.log(err);
}
```

## request(type, [...args])
| Parameter   |      Optional      |  Type | Note |
|----------|:-------------:|------:|-----:|
| type | No | String | Must be a valid Sonoran API type (AllAPITypesType) |
| ...args | Yes | Any | Arguments based on the type given to construct a proper API request |

returns *requestResult*;
| Parameter   |      Optional      |  Type | Note |
|----------|:-------------:|------:|-----:|
| requestResult | No | Any | Response body from given API request |

### Example Code
```js
const Sonoran = require('sonoran.js');
const instance = Sonoran.instance({
  communityId: 'mycommunity',
  apiKey: 'e6ba9d68-ca7a-4e59-a9e2-93e275b4e0bf',
  product: Sonoran.productEnums.CMS
});

try {
  const responseData = await instance.cms.rest.request('VERIFY_WHITELIST', '235947056630333440', undefined, instance.defaultServerId);
  console.log(responseData);
} catch (err) {
  console.log(err);
}
```