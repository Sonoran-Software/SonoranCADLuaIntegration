# Sonoran CAD Specific Methods & Usage
The following methods can be accessed from the `cad` property of an instance.

## Basic General Usage
```js
const Sonoran = require('sonoran.js');
const instance = Sonoran.instance({
  communityId: 'mycommunity',
  apiKey: 'e6ba9d68-ca7a-4e59-a9e2-93e275b4e0bf',
  product: Sonoran.productEnums.CAD
});


const whitelist = await instance.cad.getAccount('459798465498798432');
```

## getAccount(params)
| Parameter   |      Optional      |  Type | Note |
|----------|:-------------:|------:|-----:|
| params.username | Yes | String | Must have at least apiId or accId |
| params.apiId | Yes | String | Must have at least apiId or accId |

Returns *accountResult*;
| Property   |      Optional      |  Type | Note |
|----------|:-------------:|------:|-----:|
| accountResult.success | No | Boolean | Wether the whitelist verification was successful |
| accountResult.account | Yes | Object | Object of the account data |
| accountResult.reason | Yes | String | Fail reason if success is falsy |

### Example Code
```js
const Sonoran = require('sonoran.js');
const instance = Sonoran.instance({
  communityId: 'mycommunity',
  apiKey: 'e6ba9d68-ca7a-4e59-a9e2-93e275b4e0bf',
  product: Sonoran.productEnums.CMS,
  serverId: 2
});

// This will verify the whitelist of the given API ID or account ID for server id 2 as specified above
const verification = await instance.cad.getAccount('459798465498798432');
// This will verify the whitelist of the given API ID for server id 1 since I specified that
const verification = await instance.cad.getAccount({
  apiId: '459798465498798432',
  serverId: 1
});
// OR
// This will verify the whitelist of the given account ID for server id 1 since I specified that
const verification = await instance.cad.getAccount({
  accId: 'd5663516-ee35-11e9-9714-5600023b2434',
  serverId: 1
});

if (verification.success) {
  console.log('Success!', verification.reason);
} else {
  console.log('Unsuccessful', verfication.reason); // Log the reason it was unsuccessful.
}
```