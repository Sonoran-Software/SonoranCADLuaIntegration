# Sonoran CMS Specific Methods & Usage
The following methods can be accessed from the `cms` property of an instance.

## Basic General Usage
```js
const Sonoran = require('sonoran.js');
const instance = Sonoran.instance({
  communityId: 'mycommunity',
  apiKey: 'e6ba9d68-ca7a-4e59-a9e2-93e275b4e0bf',
  product: Sonoran.productEnums.CMS
});


const whitelist = await instance.cms.verifyWhitelist('459798465498798432');
```

## verifyWhitelist(whitelistOptions)
| Parameter   |      Optional      |  Type | Note |
|----------|:-------------:|------:|-----:|
| whitelistOptions | Yes | String | May just be a string if you'd like to not specify any additional options such as serverId to which will default to the 1 as default or whatever was instanciated with the instance. |
| whitelistOptions.apiId | Yes | String | Must have at least apiId or accId |
| whitelistOptions.accId | Yes | String | Must have at least apiId or accId |
| whitelistOptions.serverId | Yes | Number | Checks whitelist of specific server Id instead of default or set server ID at instance initialization.. |

Returns *whitelistResult*;
| Property   |      Optional      |  Type | Note |
|----------|:-------------:|------:|-----:|
| whitelistResult.success | No | Boolean | Wether the whitelist verification was successful |
| whitelistResult.reason | Yes | String | Username if success is truthy, fail reason if success is falsy |

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
const verification = await instance.cms.verifyWhitelist('459798465498798432');
// This will verify the whitelist of the given API ID for server id 1 since I specified that
const verification = await instance.cms.verifyWhitelist({
  apiId: '459798465498798432',
  serverId: 1
});
// OR
// This will verify the whitelist of the given account ID for server id 1 since I specified that
const verification = await instance.cms.verifyWhitelist({
  accId: 'd5663516-ee35-11e9-9714-5600023b2434',
  serverId: 1
});

if (verification.success) {
  console.log('Success!', verification.reason);
} else {
  console.log('Unsuccessful', verfication.reason); // Log the reason it was unsuccessful.
}
```

## getComAccount(params)
| Parameter   |      Optional      |  Type | Note |
|----------|:-------------:|------:|-----:|
| params.accId | Yes | String | Must have at least apiId, username or accId |
| params.username | Yes | String | Must have at least apiId, username or accId |
| params.apiId | Yes | String | Must have at least apiId, username or accId |

Returns *accountResult*;
| Property   |      Optional      |  Type | Note |
|----------|:-------------:|------:|-----:|
| accountResult.success | No | Boolean | Wether the whitelist verification was successful |
| accountResult.account | Yes | Object | Object of the account data |
| accountResult.reason | Yes | String | Fail reason if success is falsy |

### Example Account Data Object
```js
{
  accId: '67ceebae-ee63-43c1-a6a6-5234b2210abf',
  active: true,
  username: 'Dawson G.',
  comName: 'Dawson G.',
  primaryIdentifier: '1A-1',
  secondaryIdentifiers: [],
  primaryRank: 'fc2c3825-df41-4485-ad9a-6c2ac900b4f4', // Rank UUID
  secondaryRanks: [
    '331d4ece-b582-4c9c-885b-7060341cf482' // Rank UUID
  ],
  primaryDepartment: '00116ef0-9d22-491e-964c-1eb1b6ffd167', // Department UUID
  secondaryDepartments: [
    '7dbedb0e-4df2-4405-b241-cb5dee253ab8' // Department UUID
  ],
  joinDate: '2022-02-22 20:28:40.000 -0800',
  totalRankPower: 100,
  comOwner: true,
  isBanned: false,
  lastLogin: '2022-02-22 22:43:46.000 -0800',
  activeApiIds: [
    '235947056630333440'
  ]
}

```

### Example Code
```js
const Sonoran = require('sonoran.js');
const instance = Sonoran.instance({
  communityId: 'mycommunity',
  apiKey: 'e6ba9d68-ca7a-4e59-a9e2-93e275b4e0bf',
  product: Sonoran.productEnums.CMS
});

// This will get the community account with the given API ID if there's one found
const comAccount = await instance.cms.getComAccount({
  apiId: '235947056630333440'
});
// OR
// This will get the community account with the given username if there's one found
const comAccount = await instance.cms.getComAccount({
  username: 'Dawson G.'
});
// OR
// This will get the community account with the given account ID if there's one found
const comAccount = await instance.cms.getComAccount({
  accId: '67ceebae-ee63-43c1-a6a6-5234b2210abf'
});

if (comAccount.success) {
  console.log('Success! Account data:', comAccount.data);
} else {
  console.log('Unsuccessful', comAccount.reason);
}
```

## clockInOut(data)
| Parameter   |      Optional      |  Type | Note |
|----------|:-------------:|------:|-----:|
| data.apiId | Yes | String | Must have at least apiId or accId |
| data.accId | Yes | String | Must have at least apiId or accId |
| data.forceClockIn | Yes | Boolean | Will start a new clock in and overrite any current clock in |

Returns *clockResult*;
| Property   |      Optional      |  Type | Note |
|----------|:-------------:|------:|-----:|
| clockResult.success | No | Boolean | Wether the whitelist verification was successful |
| clockResult.clockedIn | Yes | Boolean | Wether the account was clocked in or out if success is truthy |
| clockResult.reason | Yes | String | Fail reason if success is falsy |

### Example Code
```js
const Sonoran = require('sonoran.js');
const instance = Sonoran.instance({
  communityId: 'mycommunity',
  apiKey: 'e6ba9d68-ca7a-4e59-a9e2-93e275b4e0bf',
  product: Sonoran.productEnums.CMS
});

// This will override any current clock in and will start a new one on the community account found by the specified API ID if found
const clockResult = await instance.cms.clockInOut({
  apiId: '235947056630333440',
  forceClockIn: true
});
// OR
// This will either clock in or out the community account found by the specified API ID if found.
// Will determine to clock in or out depending on what is pending.
const clockResult = await instance.cms.clockInOut({
  apiId: '235947056630333440'
});
// OR
// This will either clock in or out the community account found by the specified accId if found.
// Will determine to clock in or out depending on what is pending.
const clockResult = await instance.cms.clockInOut({
  accId: '67ceebae-ee63-43c1-a6a6-5234b2210abf'
});

if (clockResult.success) {
  console.log(`Success! Clocked in? ${clockResult.clockedIn ? 'Yes!' : 'No!'}`);
} else {
  console.log('Unsuccessful', comAccount.reason);
}
```

## checkComApiId(apiId)
| Parameter   |      Optional      |  Type |
|----------|:-------------:|------:|
| apiId | Yes | String |

Returns *checkResult*;
| Property   |      Optional      |  Type | Note |
|----------|:-------------:|------:|-----:|
| checkResult.success | No | Boolean | Wether the whitelist verification was successful |
| checkResult.username | Yes | String | Username for the account found with the API ID given |
| checkResult.reason | Yes | String | Fail reason if success is falsy |

### Example Code
```js
const Sonoran = require('sonoran.js');
const instance = Sonoran.instance({
  communityId: 'mycommunity',
  apiKey: 'e6ba9d68-ca7a-4e59-a9e2-93e275b4e0bf',
  product: Sonoran.productEnums.CMS
});

const checkResult = await instance.cms.checkComApiId('235947056630333440');

if (checkResult.success) {
  console.log(`Success! Account found: ${checkResult.username}`);
} else {
  console.log('Unsuccessful', checkResult.reason);
}
```