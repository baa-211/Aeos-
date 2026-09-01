<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>AEOS — Command</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@400;500;600&family=Spectral:ital,wght@0,300;0,400;1,300&family=IBM+Plex+Mono:wght@400;500&display=swap" rel="stylesheet">
<style>
:root{
  --stone:#0F0D0B; --stone-2:#1A1613; --stone-3:#262019;
  --marble:#E8E0D2; --marble-2:#BDB2A0; --marble-3:#8A8073;
  --gilt:#C9A227; --gilt-lit:#E8CB72; --gilt-dim:#7A6520;
  --moss:#7E9068; --oxide:#B4573A; --amber:#C99A3E;
  --edge:rgba(201,162,39,.16); --edge-2:rgba(232,224,210,.09);
}
*{box-sizing:border-box}
html,body{height:100%;margin:0}
body{
  background:var(--stone);color:var(--marble);overflow:hidden;
  font-family:"Spectral",Georgia,serif;font-weight:300;-webkit-font-smoothing:antialiased;
}
.mono{font-family:"IBM Plex Mono",monospace;letter-spacing:.16em;text-transform:uppercase}

/* ── chamber ── */
#chamber{position:fixed;inset:0;z-index:0;pointer-events:none;background:
  radial-gradient(78% 58% at 50% 40%,rgba(201,162,39,.13) 0%,rgba(201,162,39,0) 62%),
  radial-gradient(120% 78% at 50% 112%,rgba(232,224,210,.09) 0%,rgba(232,224,210,0) 55%),
  radial-gradient(58% 44% at 12% 8%,rgba(232,203,114,.09) 0%,rgba(0,0,0,0) 62%),
  radial-gradient(58% 44% at 88% 8%,rgba(232,203,114,.07) 0%,rgba(0,0,0,0) 62%),
  linear-gradient(178deg,#0B0A08 0%,#141110 46%,#1E1915 100%)}
#arches{position:fixed;inset:0;z-index:1;pointer-events:none;opacity:.4}
#grain{position:fixed;inset:0;z-index:2;pointer-events:none;opacity:.32;mix-blend-mode:overlay}

/* ── stage ── */
#scene{position:fixed;inset:0;z-index:3;display:block;touch-action:none}

/* ── chrome ── */
.hud{position:fixed;z-index:6}
#tl{top:26px;left:30px}
#tr{top:26px;right:30px;text-align:right}
.st{display:flex;align-items:center;gap:9px;font-size:10px;color:var(--marble-3);margin:0 0 6px}
#tr .st{justify-content:flex-end}
.st b{color:var(--marble);font-weight:500}
.pip{width:5px;height:5px;border-radius:50%;flex:none;background:var(--marble-3)}
.pip.ok{background:var(--moss);box-shadow:0 0 7px rgba(126,144,104,.8)}
.pip.warn{background:var(--amber);box-shadow:0 0 7px rgba(201,154,62,.8)}
.pip.bad{background:var(--oxide);box-shadow:0 0 7px rgba(180,87,58,.85)}
.pip.unk{background:transparent;border:1px solid var(--marble-3)}

#title{position:fixed;top:74px;left:50%;transform:translateX(-50%);z-index:6;text-align:center;pointer-events:none}
#title h1{font-family:"Cinzel",serif;font-weight:400;font-size:clamp(20px,2.7vw,34px);
  letter-spacing:.5em;text-indent:.5em;margin:0;color:var(--marble);
  text-shadow:0 0 26px rgba(232,203,114,.34)}
#title p{margin:9px 0 0;font-size:8.5px;letter-spacing:.34em;color:var(--marble-3)}

#creed{position:fixed;bottom:18px;left:50%;transform:translateX(-50%);z-index:6;
  text-align:center;pointer-events:none;width:min(94vw,760px)}
#creed .k{font-size:8.5px;letter-spacing:.44em;color:var(--gilt-dim)}
#creed .v{margin:9px 0 0;font-size:12px;font-style:italic;color:var(--marble-3)}

/* ── windows ── */
#windows{position:fixed;inset:0;z-index:8;pointer-events:none}
.win{
  position:absolute;pointer-events:auto;display:flex;flex-direction:column;
  background:linear-gradient(174deg,rgba(26,22,19,.975),rgba(14,12,10,.985));
  border:1px solid var(--edge);backdrop-filter:blur(12px);
  box-shadow:0 22px 62px rgba(0,0,0,.66);min-width:290px;min-height:52px;
  max-width:96vw;max-height:92vh;overflow:hidden}
.win.focus{border-color:rgba(201,162,39,.42);box-shadow:0 26px 74px rgba(0,0,0,.76)}
.win.collapsed{height:auto!important;min-height:0;resize:none}
.win.collapsed .win-body,.win.collapsed .win-grip{display:none}

.win-head{
  flex:none;display:flex;align-items:center;gap:10px;padding:11px 12px 11px 15px;
  border-bottom:1px solid var(--edge-2);cursor:grab;user-select:none;
  background:rgba(20,17,14,.7)}
.win-head:active{cursor:grabbing}
.win.collapsed .win-head{border-bottom:0}
.win-swatch{width:9px;height:9px;flex:none;transform:rotate(45deg);border:1px solid rgba(0,0,0,.4)}
.win-titles{flex:1;min-width:0}
.win-titles .id{font-family:"IBM Plex Mono",monospace;font-size:8px;letter-spacing:.15em;
  text-transform:uppercase;color:var(--gilt-dim);margin:0 0 3px;white-space:nowrap;
  overflow:hidden;text-overflow:ellipsis}
.win-titles h2{font-family:"Cinzel",serif;font-size:14px;font-weight:500;letter-spacing:.09em;
  margin:0;color:var(--marble);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.win-btns{flex:none;display:flex;gap:5px}
.wb{background:none;border:1px solid var(--edge);color:var(--marble-3);
  width:23px;height:23px;cursor:pointer;font-size:12px;line-height:1;font-family:inherit;padding:0}
.wb:hover{color:var(--marble);border-color:var(--gilt)}
.wb:focus-visible{outline:2px solid var(--gilt);outline-offset:2px}

.win-body{flex:1;overflow-y:auto;overscroll-behavior:contain;padding:17px 20px 22px}
.win-body::-webkit-scrollbar{width:5px}
.win-body::-webkit-scrollbar-thumb{background:var(--gilt-dim)}
.win-grip{position:absolute;right:0;bottom:0;width:17px;height:17px;cursor:nwse-resize;
  background:linear-gradient(135deg,transparent 48%,var(--gilt-dim) 48%,var(--gilt-dim) 60%,
    transparent 60%,transparent 72%,var(--gilt-dim) 72%,var(--gilt-dim) 84%,transparent 84%)}

.blk{margin:0 0 20px}
.blk:last-child{margin:0}
.blk>h3{font-size:8.5px;color:var(--gilt-dim);margin:0 0 9px;font-family:"IBM Plex Mono",monospace;
  letter-spacing:.2em;text-transform:uppercase;font-weight:500}
.blk p{margin:0;font-size:13.5px;line-height:1.75;color:var(--marble-2)}
.blk ol,.blk ul{margin:0;padding-left:17px;font-size:12.5px;line-height:1.85;color:var(--marble-2)}
.blk li{margin:0 0 4px}
.mem{border-left:2px solid var(--gilt-dim);padding:2px 0 2px 13px;margin:0 0 15px}
.mem.mine{border-left-color:var(--moss)}
.mem .d{font-family:"IBM Plex Mono",monospace;font-size:8.5px;letter-spacing:.13em;color:var(--gilt-dim)}
.mem.mine .d{color:var(--moss)}
.mem .t{font-size:13px;color:var(--marble);margin:4px 0 5px;font-weight:400}
.mem .b{font-size:12.5px;line-height:1.75;color:var(--marble-3);margin:0}
.tag{display:inline-block;font-family:"IBM Plex Mono",monospace;font-size:8px;letter-spacing:.14em;
  text-transform:uppercase;border:1px solid var(--edge);padding:3px 8px;color:var(--marble-3);margin:0 5px 5px 0}
.tag.on{border-color:var(--gilt);color:var(--gilt-lit)}
.tag.unk{border-style:dashed}
table{width:100%;border-collapse:collapse;font-size:12px}
td{padding:7px 8px;border-bottom:1px solid var(--edge-2);color:var(--marble-2);vertical-align:top}
td.k{font-family:"IBM Plex Mono",monospace;font-size:9px;letter-spacing:.1em;
  text-transform:uppercase;color:var(--marble-3);white-space:nowrap;width:33%}
.note{border:1px solid var(--edge);border-left:3px solid var(--amber);padding:13px 15px;
  font-size:12.5px;line-height:1.75;color:var(--marble-2);margin:16px 0 0}
.note b{color:var(--marble);font-weight:500}

/* ── comments ── */
textarea.cmt{width:100%;background:rgba(0,0,0,.28);border:1px solid var(--edge);
  color:var(--marble);font-family:"Spectral",Georgia,serif;font-size:13px;font-weight:300;
  line-height:1.65;padding:10px 12px;resize:vertical;min-height:74px;border-radius:0}
textarea.cmt:focus{outline:none;border-color:var(--gilt)}
textarea.cmt::placeholder{color:var(--marble-3);opacity:.6}
input.cmt-t{width:100%;background:rgba(0,0,0,.28);border:1px solid var(--edge);
  color:var(--marble);font-family:"Spectral",Georgia,serif;font-size:13px;font-weight:400;
  padding:9px 12px;margin:0 0 8px;border-radius:0}
input.cmt-t:focus{outline:none;border-color:var(--gilt)}
.cmt-row{display:flex;gap:7px;margin:9px 0 0;flex-wrap:wrap}
.btn{background:none;border:1px solid var(--edge);color:var(--marble-2);
  font-family:"IBM Plex Mono",monospace;font-size:9px;letter-spacing:.14em;text-transform:uppercase;
  padding:8px 13px;cursor:pointer}
.btn:hover{border-color:var(--gilt);color:var(--marble)}
.btn:focus-visible{outline:2px solid var(--gilt);outline-offset:2px}
.btn.primary{border-color:var(--gilt-dim);color:var(--gilt-lit)}
.btn[disabled]{opacity:.4;cursor:not-allowed}
.said{font-family:"IBM Plex Mono",monospace;font-size:9px;letter-spacing:.1em;
  color:var(--moss);margin:9px 0 0;min-height:12px}

/* ── drop ── */
#dropZone{position:fixed;inset:0;z-index:7;display:none;place-items:center;
  background:radial-gradient(58% 45% at 50% 50%,rgba(201,162,39,.11),rgba(11,10,8,.9))}
#dropZone.on{display:grid}
#dropZone .msg{text-align:center;pointer-events:none}
#dropZone .ring{width:250px;height:250px;border:1px dashed var(--gilt);border-radius:50%;
  margin:0 auto 26px;animation:pulse 1.6s ease-in-out infinite}
@keyframes pulse{0%,100%{transform:scale(1);opacity:.55}50%{transform:scale(1.055);opacity:1}}
#dropZone h2{font-family:"Cinzel",serif;font-size:19px;letter-spacing:.22em;margin:0;color:var(--gilt-lit)}
#dropZone p{margin:11px 0 0;font-size:11px;letter-spacing:.16em;color:var(--marble-3);
  font-family:"IBM Plex Mono",monospace;text-transform:uppercase}

#hint{position:fixed;bottom:66px;left:50%;transform:translateX(-50%);z-index:6;
  font-size:8.5px;letter-spacing:.24em;color:var(--marble-3);opacity:.62;pointer-events:none;
  font-family:"IBM Plex Mono",monospace;text-transform:uppercase;text-align:center}

@media (prefers-reduced-motion:reduce){#dropZone .ring{animation:none}}
@media (max-width:760px){
  .win{max-width:100vw}
  #tl,#tr{font-size:9px} #tr{right:16px} #tl{left:16px}
  #creed .v{display:none}
}
</style>
</head>
<body>

<div id="chamber"></div>
<svg id="arches" aria-hidden="true" preserveAspectRatio="none" viewBox="0 0 1440 900">
  <defs>
    <linearGradient id="col" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#3A322A" stop-opacity=".85"/>
      <stop offset="55%" stop-color="#241E19" stop-opacity=".5"/>
      <stop offset="100%" stop-color="#141110" stop-opacity="0"/>
    </linearGradient>
    <linearGradient id="glow" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#E8CB72" stop-opacity=".26"/>
      <stop offset="100%" stop-color="#E8CB72" stop-opacity="0"/>
    </linearGradient>
  </defs>
  <g fill="url(#col)">
    <path d="M40 900 L40 300 Q40 190 130 190 Q220 190 220 300 L220 900 Z"/>
    <path d="M1220 900 L1220 300 Q1220 190 1310 190 Q1400 190 1400 300 L1400 900 Z"/>
    <path d="M300 900 L300 250 Q300 120 400 120 Q500 120 500 250 L500 900 Z" opacity=".55"/>
    <path d="M940 900 L940 250 Q940 120 1040 120 Q1140 120 1140 250 L1140 900 Z" opacity=".55"/>
  </g>
  <g fill="url(#glow)">
    <path d="M230 900 L230 300 Q230 200 295 200 L295 900 Z"/>
    <path d="M1145 900 L1145 300 Q1145 200 1210 200 L1210 900 Z"/>
  </g>
</svg>
<svg id="grain" aria-hidden="true"><filter id="g"><feTurbulence type="fractalNoise" baseFrequency=".82" numOctaves="3" seed="11"/><feColorMatrix values="0 0 0 0 .55 0 0 0 0 .5 0 0 0 0 .42 0 0 0 -1.15 .6"/></filter><rect width="100%" height="100%" filter="url(#g)"/></svg>

<canvas id="scene" aria-label="AEOS engine globe and pipeline stages"></canvas>

<div class="hud mono" id="tl">
  <p class="st"><span class="pip unk" id="pipResult"></span>Result <b id="vResult">unknown</b></p>
  <p class="st"><span class="pip unk" id="pipStage"></span>Stage <b id="vStage">unknown</b></p>
  <p class="st"><span class="pip unk"></span>Version <b id="vVersion">unknown</b></p>
</div>

<div class="hud mono" id="tr">
  <p class="st">Records <b id="vRecords">—</b><span class="pip unk"></span></p>
  <p class="st">Critical <b id="vCrit">—</b><span class="pip unk" id="pipCrit"></span></p>
  <p class="st">Schema <b id="vSchema">—</b><span class="pip unk"></span></p>
</div>

<div id="title">
  <h1>AEOS</h1>
</div>

<div id="hint" class="mono">Drag a file onto the globe to begin intake · Click a stage orb or press 1–8</div>

<div id="creed">
  <p class="k mono">Integrate · Orchestrate · Elevate</p>
  <p class="v">It reports what it knows, and says so when it does not.</p>
</div>

<div id="dropZone">
  <div class="msg"><div class="ring"></div>
    <h2>RELEASE TO BEGIN INTAKE</h2>
    <p>Nothing is written. AEOS will propose, not act.</p></div>
</div>

<div id="windows"></div>

<script>
const REPORT = __REPORT__;
const STAGES = __STAGES__;

const NAMES = {
 "STAGE-01-INTAKE":"Intake","STAGE-02-DESIGN":"Design","STAGE-03-BUILD":"Build",
 "STAGE-04-QA":"QA","STAGE-05-SECURITY":"Security","STAGE-06-COMPLIANCE":"Compliance",
 "STAGE-07-RELEASE":"Release","STAGE-08-REPORT":"Report"};
const TYPE_COLOR = {REQ:[201,162,39],ADR:[126,144,104],STAGE:[232,203,114],
  AUDIT:[180,87,58],PROJECT:[232,224,210],STATUS:[189,178,160]};

/* Each stage carries its own hue, voxel texture and glyph, so the orbs are
   distinguishable by silhouette and colour before any label is read.
   Textures: band = latitude rings, lattice = ordered grid, scatter = loose,
   dense = packed shell, spiral = drawn inward, shard = broken plates. */
const STAGE_SKIN = {
  "STAGE-01-INTAKE":     {hue:[214,196,150], tex:"funnel",  glyph:"funnel"},
  "STAGE-02-DESIGN":     {hue:[166,182,196], tex:"lattice", glyph:"compass"},
  "STAGE-03-BUILD":      {hue:[206,150,92],  tex:"blocks",  glyph:"blocks"},
  "STAGE-04-QA":         {hue:[142,178,138], tex:"band",    glyph:"lens"},
  "STAGE-05-SECURITY":   {hue:[198,128,88],  tex:"dense",   glyph:"shield"},
  "STAGE-06-COMPLIANCE": {hue:[224,216,202], tex:"scatter", glyph:"scales"},
  "STAGE-07-RELEASE":    {hue:[236,204,110], tex:"spiral",  glyph:"ascend"},
  "STAGE-08-REPORT":     {hue:[178,166,190], tex:"shard",   glyph:"scroll"}
};
const FALLBACK_SKIN = {hue:[201,162,39], tex:"scatter", glyph:"scroll"};

/* Glyphs are drawn in a unit box centred on 0,0 spanning roughly -1..1. */
const GLYPH = {
  funnel(c){ c.beginPath(); c.moveTo(-1,-.72); c.lineTo(1,-.72); c.lineTo(.2,.12);
             c.lineTo(.2,.92); c.lineTo(-.2,.66); c.lineTo(-.2,.12); c.closePath(); c.stroke(); },
  compass(c){ c.beginPath(); c.moveTo(0,-.92); c.lineTo(-.62,.86); c.moveTo(0,-.92); c.lineTo(.62,.86);
              c.stroke(); c.beginPath(); c.arc(0,-.92,.16,0,7); c.stroke();
              c.beginPath(); c.moveTo(-.34,.2); c.lineTo(.34,.2); c.stroke(); },
  blocks(c){ c.strokeRect(-.9,-.1,.8,.8); c.strokeRect(.1,-.1,.8,.8); c.strokeRect(-.4,-.9,.8,.8); },
  lens(c){ c.beginPath(); c.arc(-.16,-.16,.66,0,7); c.stroke();
           c.beginPath(); c.moveTo(.32,.32); c.lineTo(.92,.92); c.stroke();
           c.beginPath(); c.moveTo(-.48,-.16); c.lineTo(-.2,.14); c.lineTo(.2,-.5); c.stroke(); },
  shield(c){ c.beginPath(); c.moveTo(0,-.94); c.lineTo(.82,-.56); c.lineTo(.82,.14);
             c.quadraticCurveTo(.82,.72,0,.96); c.quadraticCurveTo(-.82,.72,-.82,.14);
             c.lineTo(-.82,-.56); c.closePath(); c.stroke(); },
  scales(c){ c.beginPath(); c.moveTo(0,-.9); c.lineTo(0,.7); c.moveTo(-.9,-.56); c.lineTo(.9,-.56);
             c.moveTo(-.42,.7); c.lineTo(.42,.7); c.stroke();
             c.beginPath(); c.moveTo(-.9,-.56); c.lineTo(-1.14,.06); c.lineTo(-.66,.06); c.closePath(); c.stroke();
             c.beginPath(); c.moveTo(.9,-.56); c.lineTo(.66,.06); c.lineTo(1.14,.06); c.closePath(); c.stroke(); },
  ascend(c){ c.beginPath(); c.moveTo(0,-.96); c.lineTo(0,.62); c.stroke();
             c.beginPath(); c.moveTo(-.5,-.4); c.lineTo(0,-.96); c.lineTo(.5,-.4); c.stroke();
             c.beginPath(); c.moveTo(-.78,.9); c.quadraticCurveTo(0,.44,.78,.9); c.stroke(); },
  scroll(c){ c.beginPath(); c.moveTo(-.68,-.9); c.lineTo(.68,-.9); c.lineTo(.68,.9);
             c.lineTo(-.68,.9); c.closePath(); c.stroke();
             for(let i=0;i<3;i++){ const y=-.4+i*.42;
               c.beginPath(); c.moveTo(-.38,y); c.lineTo(.38,y); c.stroke(); } }
};

const $ = id => document.getElementById(id);
const esc = s => String(s ?? "").replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]));

/* ─────────── data ─────────── */
let report = REPORT, stageIds = [], activeStage = null, openStage = null;

function ingest(r){
  report = r;
  stageIds = (r.records||[]).filter(x=>x.type==="STAGE").map(x=>x.id).sort();
  activeStage = (r.pipeline && r.pipeline.current_stage) || null;
  paintHud();
  buildOrbs();
}

function paintHud(){
  const s = report.summary||{}, res = report.result||"UNKNOWN";
  $("vResult").textContent = res.toLowerCase().replace(/_/g," ");
  $("pipResult").className = "pip " + (res==="PASS"?"ok":res==="PASS_WITH_WARNINGS"?"warn":res==="FAIL"?"bad":"unk");
  $("vStage").textContent = activeStage ? NAMES[activeStage]||activeStage : "undeclared";
  $("pipStage").className = "pip " + (activeStage?"ok":"unk");
  $("vVersion").textContent = (report.project&&report.project.version) || "see manifest";
  $("vRecords").textContent = s.records_discovered ?? "—";
  $("vCrit").textContent = s.critical ?? "—";
  $("pipCrit").className = "pip " + (s.critical>0?"bad":s.critical===0?"ok":"unk");
  $("vSchema").textContent = report.schema_version || "—";
}

/* ─────────── globe ─────────── */
const cv = $("scene"), ctx = cv.getContext("2d", {alpha:true});
let W=0,H=0,DPR=1, cx=0, cy=0, R=0;
let yaw=0, pitch=-.16, tYaw=0, tPitch=-.16;
let mx=-9e9, my=-9e9, hoverOrb=-1, breathing=0, dropping=false, gy=0, bob=0;
const calm = matchMedia("(prefers-reduced-motion: reduce)").matches;

function resize(){
  DPR = Math.min(devicePixelRatio||1, 2);
  W = innerWidth; H = innerHeight;
  cv.width = W*DPR; cv.height = H*DPR;
  cv.style.width = W+"px"; cv.style.height = H+"px";
  ctx.setTransform(DPR,0,0,DPR,0,0);
  cx = W/2; cy = H*0.355;
  R = Math.min(W*0.17, H*0.235, 228);
}
addEventListener("resize", ()=>{ resize(); plateKey=""; });

/* voxels: a fibonacci sphere, tinted by the records the engine actually holds */
const VOX = [];
function buildVoxels(){
  VOX.length = 0;
  const recs = report.records || [];
  const N = 1150;
  const phi = Math.PI*(3-Math.sqrt(5));
  for(let i=0;i<N;i++){
    const y = 1 - (i/(N-1))*2;
    const r = Math.sqrt(Math.max(0,1-y*y));
    const th = phi*i;
    // continents: coherent blobs so the sphere reads as a world, not noise
    const n = Math.sin(th*2.1)*Math.cos(y*3.4) + Math.sin(y*5.7+th*.8)*.55;
    const land = n > .18;
    let col;
    if (i < recs.length){                       // real records occupy real voxels
      col = TYPE_COLOR[recs[i].type] || [189,178,160];
    } else col = land ? [124,138,96] : [92,96,104];
    VOX.push({x:Math.cos(th)*r, y, z:Math.sin(th)*r,
              c:col, land, rec: i<recs.length ? recs[i] : null,
              s: i<recs.length ? 1.32 : (land?1:.82), lift:0});
  }
}

const ORBS = [];
function buildOrbs(){
  ORBS.length = 0;
  const ids = stageIds.length ? stageIds : Object.keys(NAMES);
  ids.forEach((id,i)=>{
    const skin = STAGE_SKIN[id] || FALLBACK_SKIN;
    ORBS.push({id, name:NAMES[id]||id, i, x:0, y:0, r:0, glow:0,
               hue:skin.hue, tex:skin.tex, glyph:skin.glyph});
  });
}

function project(p, sy, cyaw, sp, cp){
  let x = p.x*cyaw - p.z*sy;
  let z = p.x*sy   + p.z*cyaw;
  let y = p.y*cp   - z*sp;
  z     = p.y*sp   + z*cp;
  return {x,y,z};
}

function frame(t){
  ctx.clearRect(0,0,W,H);
  if(!calm){ tYaw += .0016; breathing = Math.sin(t/1750)*.5+.5; bob = Math.sin(t/2600); }

  yaw   += (tYaw   - yaw)   * .05;
  pitch += (tPitch - pitch) * .06;

  const sy=Math.sin(yaw), cyaw=Math.cos(yaw), sp=Math.sin(pitch), cp=Math.cos(pitch);
  const rad = R * (1 + breathing*.012 + (dropping?.075:0));
  gy = cy + bob*rad*.035 - (dropping ? rad*.05 : 0);   // suspended, never resting

  const B = layoutOrbs(rad);
  drawPlate(rad, t, B);

  /* halo */
  const halo = ctx.createRadialGradient(cx,gy,rad*.55,cx,gy,rad*2.15);
  halo.addColorStop(0,`rgba(232,203,114,${.15+breathing*.05+(dropping?.14:0)})`);
  halo.addColorStop(1,"rgba(232,203,114,0)");
  ctx.fillStyle=halo; ctx.beginPath(); ctx.arc(cx,gy,rad*2.15,0,7); ctx.fill();

  /* voxels */
  const pts = [];
  for(const v of VOX){
    const p = project(v, sy, cyaw, sp, cp);
    const persp = 1/(1 + p.z*.34);
    const sx = cx + p.x*rad*persp, syy = gy + p.y*rad*persp;
    // cursor repulsion: the surface answers the pointer
    const dx = sx-mx, dy = syy-my, d2 = dx*dx+dy*dy;
    const near = d2 < 12000 && p.z > -.35;
    v.lift += ((near ? (1 - Math.sqrt(d2)/110) : 0) - v.lift) * .16;
    pts.push({sx,syy,z:p.z,v,persp,lift:v.lift});
  }
  pts.sort((a,b)=>b.z-a.z);

  for(const p of pts){
    if(p.z > 1.02) continue;
    const shade = Math.max(.14, (1 - p.z)*.55);
    const [r,g,b] = p.v.c;
    const boost = p.lift*.9 + (dropping?.3:0);
    const sz = Math.max(.9, 3.5*p.v.s*p.persp*(1+p.lift*.6));
    const off = p.lift*13;
    const nx = p.sx + (p.sx-cx)*off/rad, ny = p.syy + (p.syy-gy)*off/rad;
    ctx.fillStyle = `rgba(${Math.min(255,r+boost*150)|0},${Math.min(255,g+boost*130)|0},${Math.min(255,b+boost*80)|0},${Math.min(1,shade+boost*.55)})`;
    ctx.fillRect(nx-sz/2, ny-sz/2, sz, sz);
  }

  drawOrbs(rad, t);
  requestAnimationFrame(frame);
}

/* The plate is a slab of marble. Its base — stone, veining, polished rim — is
   static, so it is rendered once to an offscreen canvas and blitted each frame.
   Only the light inlaid in its channels animates. */
let plateCache = null, plateKey = "";

function buildPlate(rad, B){
  const rx = B.rx, ry = B.ry;
  const pad = 26;
  const w = Math.ceil((rx+pad)*2), h = Math.ceil((ry+pad)*2);
  const off = document.createElement("canvas");
  off.width = w*DPR; off.height = h*DPR;
  const c = off.getContext("2d");
  c.setTransform(DPR,0,0,DPR,0,0);
  const ox = w/2, oy = h/2;

  c.save();
  c.beginPath(); c.ellipse(ox,oy,rx,ry,0,0,7); c.clip();

  // stone body: lit from the upper left, falling into shadow at the far rim
  const body = c.createLinearGradient(ox-rx*.6, oy-ry, ox+rx*.5, oy+ry);
  body.addColorStop(0,   "#4A4239");
  body.addColorStop(0.34,"#3A332C");
  body.addColorStop(0.72,"#272119");
  body.addColorStop(1,   "#191410");
  c.fillStyle = body;
  c.fillRect(0,0,w,h);

  // veining — quiet, irregular, never symmetrical
  const veins = [
    [-1.00,-0.30, -0.30,-0.62, 0.34,-0.16, 1.00,-0.44, 0.34],
    [-1.00, 0.42, -0.36, 0.10, 0.22, 0.56, 1.00, 0.20, 0.26],
    [-0.86,-0.72, -0.10,-0.20, 0.40,-0.74, 0.92,-0.30, 0.20],
    [-0.70, 0.80, -0.02, 0.34, 0.46, 0.86, 1.00, 0.62, 0.16],
    [-1.00, 0.02, -0.42,-0.34, 0.30, 0.30, 1.00,-0.06, 0.22]
  ];
  c.lineCap = "round";
  for(const [x1,y1,cx1,cy1,cx2,cy2,x2,y2,a] of veins){
    c.beginPath();
    c.moveTo(ox+x1*rx, oy+y1*ry);
    c.bezierCurveTo(ox+cx1*rx, oy+cy1*ry, ox+cx2*rx, oy+cy2*ry, ox+x2*rx, oy+y2*ry);
    c.strokeStyle = `rgba(214,204,186,${a*0.5})`; c.lineWidth = 1.6; c.stroke();
    c.strokeStyle = `rgba(232,224,210,${a*0.22})`; c.lineWidth = 0.7; c.stroke();
  }

  // fine grain so the stone is not flat
  for(let i=0;i<340;i++){
    const a = Math.random()*6.283, r = Math.sqrt(Math.random());
    c.fillStyle = `rgba(232,224,210,${Math.random()*0.05})`;
    c.fillRect(ox+Math.cos(a)*r*rx, oy+Math.sin(a)*r*ry, 1.4, 1.4);
  }

  // sheen across the polished face
  const sheen = c.createLinearGradient(ox-rx, oy-ry*.8, ox+rx*.3, oy+ry);
  sheen.addColorStop(0,"rgba(255,248,232,.085)");
  sheen.addColorStop(.42,"rgba(255,248,232,.015)");
  sheen.addColorStop(1,"rgba(0,0,0,.16)");
  c.fillStyle = sheen; c.fillRect(0,0,w,h);
  c.restore();

  // polished edge catching the chamber light
  c.beginPath(); c.ellipse(ox,oy,rx,ry,0,0,7);
  c.strokeStyle = "rgba(226,214,192,.34)"; c.lineWidth = 1.4; c.stroke();
  c.beginPath(); c.ellipse(ox,oy,rx-2.2,ry-2.2,0,0,7);
  c.strokeStyle = "rgba(0,0,0,.34)"; c.lineWidth = 2; c.stroke();

  return {canvas:off, w, h, rx, ry};
}

function drawPlate(rad, t, B){
  const py = B.cy;
  const key = `${Math.round(B.rx)}x${Math.round(B.ry)}x${Math.round(py)}x${DPR}`;
  if(plateKey !== key){ plateCache = buildPlate(rad, B); plateKey = key; }
  const P = plateCache;

  // slab shadow, grounding it in the chamber
  ctx.save();
  ctx.fillStyle = "rgba(0,0,0,.5)";
  ctx.beginPath(); ctx.ellipse(cx, py+rad*.10, P.rx*.98, P.ry*.9, 0, 0, 7); ctx.fill();
  ctx.restore();

  ctx.drawImage(P.canvas, cx-P.w/2, py-P.h/2, P.w, P.h);

  // ── light inlaid in the channels ──
  // A groove cut into the stone, with light lying inside it. The dark line
  // is the cut; the bright line is what fills it.
  ctx.save();
  ctx.beginPath(); ctx.ellipse(cx,py,P.rx,P.ry,0,0,7); ctx.clip();

  const rings = [0.40, 0.60, 0.80, 0.965];
  rings.forEach((f,i)=>{
    const rx = P.rx*f, ry = P.ry*f;
    const live = calm ? 1 : 0.82 + Math.sin(t/1900 + i*1.15)*0.18;
    const lit  = live * (dropping ? 1.5 : 1);

    ctx.beginPath(); ctx.ellipse(cx,py+1.4,rx,ry,0,0,7);
    ctx.strokeStyle = "rgba(0,0,0,.52)"; ctx.lineWidth = 3.2; ctx.stroke();

    ctx.save();
    ctx.shadowColor = `rgba(232,203,114,${.5*lit})`;
    ctx.shadowBlur = 11;
    ctx.beginPath(); ctx.ellipse(cx,py,rx,ry,0,0,7);
    ctx.strokeStyle = `rgba(201,162,39,${.34*lit})`; ctx.lineWidth = 2.4; ctx.stroke();
    ctx.beginPath(); ctx.ellipse(cx,py,rx,ry,0,0,7);
    ctx.strokeStyle = `rgba(255,240,196,${.62*lit})`; ctx.lineWidth = .9; ctx.stroke();
    ctx.restore();
  });

  // radial channels, quieter than the rings
  for(let k=0;k<12;k++){
    const a = (k/12)*6.283;
    const live = calm ? .5 : .35 + Math.sin(t/2300 + k*.5)*.18;
    ctx.beginPath();
    ctx.moveTo(cx+Math.cos(a)*P.rx*.42, py+Math.sin(a)*P.ry*.42);
    ctx.lineTo(cx+Math.cos(a)*P.rx*1.0, py+Math.sin(a)*P.ry*1.0);
    ctx.strokeStyle = `rgba(201,162,39,${.16*live})`; ctx.lineWidth = 1; ctx.stroke();
  }

  // the suspended globe pools light on the stone beneath it
  const pool = ctx.createRadialGradient(cx, py, 0, cx, py, P.rx*.62);
  pool.addColorStop(0, `rgba(232,203,114,${.20+breathing*.05+(dropping?.14:0)})`);
  pool.addColorStop(.45,`rgba(232,203,114,${.06+breathing*.02})`);
  pool.addColorStop(1,  "rgba(232,203,114,0)");
  ctx.fillStyle = pool;
  ctx.beginPath(); ctx.ellipse(cx,py,P.rx*.62,P.ry*.62,0,0,7); ctx.fill();
  ctx.restore();
}

function texturePoints(tex, k, n, spin){
  /* returns {x,y,z} on a unit sphere; each texture arranges its shell
     differently so the orbs differ by surface, not only by colour */
  const g = 2.39996;
  switch(tex){
    case "band": {                       // stacked latitude rings
      const row = Math.floor(k/9), col = k%9;
      const yy = 1 - (row/5)*2, rr = Math.sqrt(Math.max(0,1-yy*yy));
      const th = (col/9)*6.283 + spin;
      return {x:Math.cos(th)*rr, y:yy, z:Math.sin(th)*rr};
    }
    case "lattice": {                    // ordered grid
      const row = Math.floor(k/8), col = k%8;
      const yy = 1 - (row/6.2)*2, rr = Math.sqrt(Math.max(0,1-yy*yy));
      const th = (col/8)*6.283 + row*.14 + spin;
      return {x:Math.cos(th)*rr, y:yy, z:Math.sin(th)*rr};
    }
    case "blocks": {                     // coarse, few large plates
      const yy = 1 - (Math.floor(k/6)/4.4)*2, rr = Math.sqrt(Math.max(0,1-yy*yy));
      const th = (Math.floor(k%6)/6)*6.283 + spin;
      return {x:Math.cos(th)*rr, y:yy, z:Math.sin(th)*rr};
    }
    case "dense": {                      // packed protective shell
      const yy = 1-(k/(n-1))*2, rr = Math.sqrt(Math.max(0,1-yy*yy));
      const th = g*k + spin;
      return {x:Math.cos(th)*rr, y:yy, z:Math.sin(th)*rr};
    }
    case "spiral": {                     // drawn upward and inward
      const f = k/n, yy = 1-f*2, rr = Math.sqrt(Math.max(0,1-yy*yy));
      const th = f*22 + spin;
      return {x:Math.cos(th)*rr, y:yy, z:Math.sin(th)*rr};
    }
    case "shard": {                      // broken plates with gaps
      if(k%3===2) return null;
      const yy = 1-(k/(n-1))*2, rr = Math.sqrt(Math.max(0,1-yy*yy));
      const th = g*k*1.7 + spin;
      return {x:Math.cos(th)*rr, y:yy, z:Math.sin(th)*rr};
    }
    case "funnel": {                     // heavier at the top, tapering down
      const f = Math.pow(k/n, .55), yy = 1-f*2, rr = Math.sqrt(Math.max(0,1-yy*yy));
      const th = g*k + spin;
      return {x:Math.cos(th)*rr, y:yy, z:Math.sin(th)*rr};
    }
    default: {                           // scatter
      const yy = 1-(k/(n-1))*2, rr = Math.sqrt(Math.max(0,1-yy*yy));
      const th = g*k*1.31 + spin;
      return {x:Math.cos(th)*rr, y:yy, z:Math.sin(th)*rr};
    }
  }
}

function drawGlyph(o, lum){
  const g = GLYPH[o.glyph]; if(!g) return;
  const s = o.r*0.52;
  ctx.save();
  ctx.translate(o.x, o.y);
  ctx.scale(s, s);
  ctx.lineWidth = Math.max(.10, 1.5/s);
  ctx.lineJoin = "round"; ctx.lineCap = "round";
  // dark backing so the glyph reads against a lit shell
  ctx.strokeStyle = `rgba(12,10,8,${.55*lum})`;
  ctx.lineWidth = Math.max(.20, 3.2/s);
  g(ctx);
  ctx.strokeStyle = `rgba(255,246,224,${Math.min(1,.62+lum*.38)})`;
  ctx.lineWidth = Math.max(.10, 1.5/s);
  g(ctx);
  ctx.restore();
}

function layoutOrbs(rad){
  const py = cy + rad*1.34, rx = Math.min(W*0.38, rad*2.5), ry = rad*.30;
  const tight = W < 700;
  const n = ORBS.length || 8;
  ORBS.forEach((o,i)=>{
    o.r = (tight ? Math.min(W*0.062, 25) : rad*.132) * (1 + o.glow*.10);
    if(tight){
      const col = i%4, row = Math.floor(i/4);
      const gap = Math.min(W*0.22, 92);
      o.x = cx + (col-1.5)*gap;
      o.y = py + rad*.10 + row*Math.min(W*0.20, 84);
    } else {
      const a = Math.PI - Math.PI*(i+.5)/n;
      o.x = cx + Math.cos(a)*rx;
      o.y = py + Math.sin(a)*ry;
    }
  });
  const xs = ORBS.map(o=>o.x), ys = ORBS.map(o=>o.y);
  const pad = (ORBS[0] ? ORBS[0].r : rad*.13) * 2.4;
  const midY = (Math.min(...ys) + Math.max(...ys)) / 2;
  return {
    tight,
    cy: midY,
    rx: Math.max(rad*2.4, Math.max(...xs.map(x=>Math.abs(x-cx))) + pad),
    ry: Math.max(rad*0.5,  Math.max(...ys.map(y=>Math.abs(y-midY))) + pad*0.9)
  };
}

function drawOrbs(rad, t){
  /* Orbs sit on the FRONT rim of the platform, entirely below the globe, so
     nothing they need for interaction is ever occluded by the sphere. */
  const tight = W < 700;   // no room for word labels; glyph and number carry it
  ORBS.forEach((o,i)=>{
    const isActive = o.id === activeStage, isOpen = o.id === openStage;
    const target = (isActive?1:.34) + (i===hoverOrb?.5:0) + (isOpen?.4:0);
    o.glow += (Math.min(1.7,target) - o.glow)*.12;

    const [hr,hg,hb] = o.hue;

    // seated shadow, so each orb rests on the rim rather than floating
    ctx.save();
    ctx.fillStyle = "rgba(0,0,0,.34)";
    ctx.beginPath(); ctx.ellipse(o.x, o.y+o.r*1.10, o.r*.88, o.r*.20, 0, 0, 7); ctx.fill();
    ctx.restore();

    // aura in the stage's own hue
    const g = ctx.createRadialGradient(o.x,o.y,o.r*.4,o.x,o.y,o.r*3.1);
    g.addColorStop(0,`rgba(${hr},${hg},${hb},${.30*o.glow})`);
    g.addColorStop(1,`rgba(${hr},${hg},${hb},0)`);
    ctx.fillStyle=g; ctx.beginPath(); ctx.arc(o.x,o.y,o.r*3.1,0,7); ctx.fill();

    // core so glyphs have something to sit on
    const core = ctx.createRadialGradient(o.x-o.r*.3,o.y-o.r*.35,o.r*.1,o.x,o.y,o.r);
    core.addColorStop(0,`rgba(${hr},${hg},${hb},${.20+o.glow*.26})`);
    core.addColorStop(1,`rgba(20,17,14,${.62+ (1-o.glow)*.2})`);
    ctx.fillStyle=core; ctx.beginPath(); ctx.arc(o.x,o.y,o.r,0,7); ctx.fill();

    // textured voxel shell
    const N = o.tex==="blocks" ? 30 : o.tex==="dense" ? 88 : 58;
    const spin = calm ? 0 : t/2900 + i;
    const pulse = isActive && !calm ? Math.sin(t/560+i)*.13+.87 : 1;
    for(let k=0;k<N;k++){
      const p = texturePoints(o.tex, k, N, spin);
      if(!p || p.z < -.1) continue;
      const sz = Math.max(1.3, o.r*(o.tex==="blocks"?.34:o.tex==="dense"?.17:.24)*(1+p.z*.34));
      const lum = (.34 + o.glow*.56) * (.5+p.z*.5) * pulse;
      ctx.fillStyle = `rgba(${Math.min(255,hr+40)|0},${Math.min(255,hg+34)|0},${Math.min(255,hb+22)|0},${Math.min(.96,lum)})`;
      ctx.fillRect(o.x+p.x*o.r-sz/2, o.y+p.y*o.r-sz/2, sz, sz);
    }

    drawGlyph(o, o.glow);

    // ring marks the stage AEOS declares current
    if(isActive){
      ctx.strokeStyle=`rgba(${hr},${hg},${hb},${.42+(calm?0:Math.sin(t/620)*.18)})`;
      ctx.lineWidth=1.2; ctx.beginPath(); ctx.arc(o.x,o.y,o.r*1.62,0,7); ctx.stroke();
    }
    if(i===hoverOrb || isOpen){
      ctx.strokeStyle="rgba(255,246,224,.5)"; ctx.lineWidth=1;
      ctx.beginPath(); ctx.arc(o.x,o.y,o.r*1.34,0,7); ctx.stroke();
    }

    // label
    ctx.textAlign="center";
    ctx.font = `500 8px "IBM Plex Mono",monospace`;
    ctx.fillStyle = isActive?`rgba(${hr},${hg},${hb},.95)`:"rgba(138,128,115,.6)";
    ctx.fillText(String(i+1).padStart(2,"0"), o.x, o.y+o.r*1.62+13);
    if(!tight || i===hoverOrb || isActive){
      ctx.font = `${i===hoverOrb||isActive?"500":"400"} 9px "IBM Plex Mono",monospace`;
      ctx.fillStyle = isActive ? `rgba(${Math.min(255,hr+26)},${Math.min(255,hg+26)},${Math.min(255,hb+26)},.96)`
                    : i===hoverOrb ? "rgba(232,224,210,.92)" : "rgba(138,128,115,.72)";
      ctx.fillText(o.name.toUpperCase(), o.x, o.y+o.r*1.62+25);
    }
  });
}

/* ─────────── interaction ─────────── */
addEventListener("pointermove", e => {
  mx = e.clientX; my = e.clientY;
  tYaw   += ((e.clientX/W - .5) * .0009);
  tPitch = -.16 + (e.clientY/H - .5) * .30;
  let h = -1;
  ORBS.forEach((o,i)=>{ if(Math.hypot(e.clientX-o.x, e.clientY-o.y) < o.r*1.55) h=i; });
  if(h!==hoverOrb){ hoverOrb=h; cv.style.cursor = h>=0 ? "pointer" : "default"; }
});
addEventListener("pointerleave", ()=>{ mx=my=-9e9; });
cv.addEventListener("click", e => {
  const hit = ORBS.find(o => Math.hypot(e.clientX-o.x, e.clientY-o.y) < o.r*1.55);
  if(hit) showStage(hit.id);
});
addEventListener("keydown", e => {
  if(e.key === "Escape"){
    const focused = [...WINS.values()].find(w=>w.el.classList.contains("focus"));
    if(focused) closeWin(focused.key); else closePanels();
    return;
  }
  if(e.key.toLowerCase() === "w" && (e.metaKey||e.ctrlKey)){ e.preventDefault(); closePanels(); return; }
  const tag = (e.target.tagName||"").toLowerCase();
  if(tag === "input" || tag === "textarea") return;
  const n = parseInt(e.key,10);
  if(n>=1 && n<=8 && ORBS[n-1]) showStage(ORBS[n-1].id);
});

/* ─────────── window manager ─────────── */
const WINS = new Map();
let zTop = 10, cascade = 0;

function focusWin(w){
  WINS.forEach(x => x.el.classList.remove("focus"));
  w.el.classList.add("focus");
  w.el.style.zIndex = ++zTop;
}

function closeWin(key){
  const w = WINS.get(key);
  if(!w) return;
  w.el.remove();
  WINS.delete(key);
  if(key.startsWith("stage:")) openStage = null;
}

function closePanels(){ [...WINS.keys()].forEach(closeWin); cascade = 0; }

function makeWindow(key, {id, title, hue, width, height}){
  if(WINS.has(key)){ const w = WINS.get(key); focusWin(w); return w; }

  const el = document.createElement("section");
  el.className = "win";
  el.setAttribute("role","dialog");
  el.setAttribute("aria-label", title);
  el.innerHTML = `
    <div class="win-head">
      <span class="win-swatch" style="background:rgb(${hue.join(",")})"></span>
      <div class="win-titles"><p class="id">${esc(id)}</p><h2>${esc(title)}</h2></div>
      <div class="win-btns">
        <button class="wb" data-a="collapse" aria-label="Collapse" title="Collapse">–</button>
        <button class="wb" data-a="close" aria-label="Close" title="Close">×</button>
      </div>
    </div>
    <div class="win-body"></div>
    <div class="win-grip" title="Resize"></div>`;

  const w = {el, key, collapsed:false, body: el.querySelector(".win-body")};

  // cascade from the right so a stack stays readable
  const ww = Math.min(width, innerWidth - 40), hh = Math.min(height, innerHeight - 80);
  const step = (cascade++ % 6) * 26;
  el.style.width  = ww + "px";
  el.style.height = hh + "px";
  el.style.left   = Math.max(12, innerWidth - ww - 34 - step) + "px";
  el.style.top    = Math.max(12, 96 + step) + "px";

  $("windows").appendChild(el);
  WINS.set(key, w);
  focusWin(w);

  el.addEventListener("pointerdown", () => focusWin(w), true);
  el.querySelector('[data-a="close"]').onclick = e => { e.stopPropagation(); closeWin(key); };
  el.querySelector('[data-a="collapse"]').onclick = e => {
    e.stopPropagation();
    w.collapsed = !w.collapsed;
    el.classList.toggle("collapsed", w.collapsed);
    e.target.textContent = w.collapsed ? "▢" : "–";
    e.target.title = w.collapsed ? "Expand" : "Collapse";
  };

  drag(el.querySelector(".win-head"), (dx,dy,s0) => {
    el.style.left = clamp(s0.left+dx, -ww+70, innerWidth-70) + "px";
    el.style.top  = clamp(s0.top +dy, 0, innerHeight-42) + "px";
  }, () => ({left: el.offsetLeft, top: el.offsetTop}));

  drag(el.querySelector(".win-grip"), (dx,dy,s0) => {
    el.style.width  = Math.max(290, Math.min(innerWidth-20,  s0.w+dx)) + "px";
    el.style.height = Math.max(120, Math.min(innerHeight-20, s0.h+dy)) + "px";
  }, () => ({w: el.offsetWidth, h: el.offsetHeight}));

  return w;
}

const clamp = (v,a,b) => Math.max(a, Math.min(b, v));

function drag(handle, move, snapshot){
  handle.addEventListener("pointerdown", e => {
    if(e.button !== 0) return;
    e.preventDefault();
    const sx = e.clientX, sy = e.clientY, s0 = snapshot();
    handle.setPointerCapture(e.pointerId);
    const onMove = ev => move(ev.clientX-sx, ev.clientY-sy, s0);
    const onUp = () => {
      handle.removeEventListener("pointermove", onMove);
      handle.removeEventListener("pointerup", onUp);
      handle.removeEventListener("pointercancel", onUp);
    };
    handle.addEventListener("pointermove", onMove);
    handle.addEventListener("pointerup", onUp);
    handle.addEventListener("pointercancel", onUp);
  });
}

/* ─────────── comments ─────────── */
/* Comments are drafted here and exported as record entries. They are NOT
   project state: the preview must not become a second source of truth, and
   a note that lives only in a browser is hidden state by definition. Drafts
   persist locally as a convenience and say plainly that they are unsaved. */
const NOTE_KEY = id => "aeos.notes." + id;

function loadNotes(id){
  try { return JSON.parse(localStorage.getItem(NOTE_KEY(id)) || "[]"); }
  catch { return (window.__mem ||= {})[id] || []; }
}
function saveNotes(id, list){
  try { localStorage.setItem(NOTE_KEY(id), JSON.stringify(list)); }
  catch { (window.__mem ||= {})[id] = list; }
}

const today = () => new Date().toISOString().slice(0,10);

function recordMarkdown(id, notes){
  return notes.map(n => `### ${n.date} — ${n.title}\n${n.body}\n`).join("\n");
}

function renderNotes(w, id){
  const notes = loadNotes(id);
  const list = w.el.querySelector("[data-notes]");
  const exp  = w.el.querySelector('[data-a="export"]');
  const clr  = w.el.querySelector('[data-a="clear"]');
  list.innerHTML = notes.length
    ? notes.map((n,i)=>`<div class="mem mine">
        <p class="d">${esc(n.date)} · unsaved draft</p>
        <p class="t">${esc(n.title)}</p>
        <p class="b">${esc(n.body)}</p>
        <button class="btn" data-del="${i}" style="margin-top:8px;padding:5px 10px">Remove</button>
      </div>`).join("")
    : `<p style="font-size:12.5px;color:var(--marble-3);margin:0">No drafted comments for this stage.</p>`;
  if(exp) exp.disabled = !notes.length;
  if(clr) clr.disabled = !notes.length;
  list.querySelectorAll("[data-del]").forEach(b => b.onclick = () => {
    const next = loadNotes(id); next.splice(+b.dataset.del, 1);
    saveNotes(id, next); renderNotes(w, id);
  });
}

function wireComments(w, id){
  const t = w.el.querySelector("[data-title]");
  const b = w.el.querySelector("[data-body]");
  const said = w.el.querySelector("[data-said]");
  const flash = m => { said.textContent = m; setTimeout(()=>{ said.textContent=""; }, 3200); };

  w.el.querySelector('[data-a="add"]').onclick = () => {
    const title = t.value.trim(), body = b.value.trim();
    if(!body){ flash("A comment needs a body."); b.focus(); return; }
    const next = loadNotes(id);
    next.push({date: today(), title: title || "Note", body});
    saveNotes(id, next);
    t.value = ""; b.value = "";
    renderNotes(w, id);
    flash("Drafted. Not in the record until you paste it there.");
  };

  w.el.querySelector('[data-a="export"]').onclick = async () => {
    const md = recordMarkdown(id, loadNotes(id));
    try { await navigator.clipboard.writeText(md); flash("Copied. Paste under ## Memory in the stage record."); }
    catch { 
      const ta = document.createElement("textarea");
      ta.value = md; ta.style.cssText = "position:fixed;opacity:0";
      document.body.appendChild(ta); ta.select();
      try { document.execCommand("copy"); flash("Copied. Paste under ## Memory in the stage record."); }
      catch { flash("Copy failed — select the text manually."); }
      ta.remove();
    }
  };

  w.el.querySelector('[data-a="clear"]').onclick = () => {
    if(!confirm("Discard all drafted comments for this stage?")) return;
    saveNotes(id, []); renderNotes(w, id);
  };

  renderNotes(w, id);
}

/* ─────────── stage window ─────────── */
function showStage(id){
  const s = STAGES[id];
  const skin = STAGE_SKIN[id] || FALLBACK_SKIN;
  const rec = (report.records||[]).find(r=>r.id===id);
  const isActive = id === activeStage;
  openStage = id;

  const w = makeWindow("stage:"+id, {
    id: id + (rec?.status ? " · " + rec.status : ""),
    title: NAMES[id] || id,
    hue: skin.hue, width: 430, height: Math.min(640, innerHeight-140)
  });

  let html = `<div class="blk" style="display:flex;align-items:center;gap:14px">
      <canvas class="spGlyph" width="52" height="52" style="flex:none"></canvas>
      <span class="tag ${isActive?"on":"unk"}">${isActive?"Declared current stage":"Not the declared stage"}</span>
    </div>`;

  if(!s){
    html += `<div class="blk"><p>No stage record content is embedded for this identifier.</p></div>`;
  } else {
    html += `<div class="blk"><h3>Purpose</h3><p>${esc(s.purpose)}</p></div>`;
    if(s.principles?.length)
      html += `<div class="blk"><h3>Principles</h3><ul>${s.principles.map(x=>`<li>${esc(x.replace(/^\d+\.\s*/,""))}</li>`).join("")}</ul></div>`;
    if(s.protocol?.length)
      html += `<div class="blk"><h3>Protocol</h3><ol>${s.protocol.map(x=>`<li>${esc(x.replace(/^\d+\.\s*/,""))}</li>`).join("")}</ol></div>`;
    if(s.gate?.length)
      html += `<div class="blk"><h3>Exit Gate</h3><ul>${s.gate.map(x=>`<li>${esc(x)}</li>`).join("")}</ul></div>`;
  }

  // comments on the work at this stage
  html += `<div class="blk"><h3>Comments on this stage's work</h3>
      <input class="cmt-t" data-title placeholder="Short title — what this is about">
      <textarea class="cmt" data-body placeholder="What happened, what you decided, what is still unknown."></textarea>
      <div class="cmt-row">
        <button class="btn primary" data-a="add">Add comment</button>
        <button class="btn" data-a="export">Copy for record</button>
        <button class="btn" data-a="clear">Discard all</button>
      </div>
      <p class="said" data-said></p>
      <div data-notes style="margin-top:16px"></div>
      <div class="note"><b>Drafts live in this browser only.</b>
        They are not project state. AEOS records are the single home for notes —
        use <em>Copy for record</em> and paste under <code>## Memory</code> in
        <code>${esc(rec?.path || "the stage record")}</code>, then commit. Until then, nothing here is real.</div>
    </div>`;

  if(s?.memory?.length)
    html += `<div class="blk"><h3>Recorded memory · ${s.memory.length} entr${s.memory.length===1?"y":"ies"}</h3>` +
      s.memory.map(m=>`<div class="mem"><p class="d">${esc(m.date)} · in record</p><p class="t">${esc(m.title)}</p><p class="b">${esc(m.body)}</p></div>`).join("") + `</div>`;

  const rel = (report.findings||[]).filter(f =>
    id==="STAGE-05-SECURITY" ? /SEC/.test(f.rule) : id==="STAGE-08-REPORT" ? /VER|DOC/.test(f.rule) : false);
  html += `<div class="blk"><h3>Findings at this gate</h3>` +
    (rel.length ? `<table>${rel.map(f=>`<tr><td class="k">${esc(f.severity)}</td><td>${esc(f.message)}</td></tr>`).join("")}</table>`
                : `<p>None reported. AEOS surfaces findings for the Security and Report gates; the other six have no automated check yet, so their state is unknown rather than passing.</p>`) + `</div>`;

  if(rec) html += `<div class="blk"><h3>Record</h3><p><code>${esc(rec.path)}</code></p></div>`;

  w.body.innerHTML = html;

  const gc = w.el.querySelector(".spGlyph");
  if(gc && GLYPH[skin.glyph]){
    const c = gc.getContext("2d");
    c.translate(26,26); c.scale(19,19);
    c.lineJoin="round"; c.lineCap="round";
    c.strokeStyle=`rgb(${skin.hue.join(",")})`;
    c.lineWidth=1.6/19;
    GLYPH[skin.glyph](c);
  }

  wireComments(w, id);
}

/* ─────────── drop intake ─────────── */
let dragDepth = 0;
addEventListener("dragenter", e => { e.preventDefault(); if(++dragDepth===1){ $("dropZone").classList.add("on"); dropping=true; } });
addEventListener("dragover", e => e.preventDefault());
addEventListener("dragleave", e => { e.preventDefault(); if(--dragDepth<=0){ dragDepth=0; $("dropZone").classList.remove("on"); dropping=false; } });
addEventListener("drop", e => {
  e.preventDefault(); dragDepth=0;
  $("dropZone").classList.remove("on"); dropping=false;
  const files = [...(e.dataTransfer?.files||[])];
  if(files.length) proposeIntake(files);
});

const CLASSIFY = [
  [/^aeos\.ya?ml$/i,          "AEOS manifest",        "Authoritative. Project version, level and security policy."],
  [/^(PROJECT|STATUS)\.md$/i, "AEOS record",          "Versioned record. Must agree with the manifest or AEOS-VER-001 blocks."],
  [/^(REQ|ADR|CHG|AUDIT|STAGE)[-_]/i, "AEOS record",  "Frontmatter record. Enters the index and reference graph."],
  [/\.go$/i,                  "Source",               "Build and QA gates apply. Must pass gofmt and vet."],
  [/\.(ya?ml|toml|json|ini|cfg|conf)$/i, "Configuration", "Configuration is data, never executable."],
  [/\.(pem|key|p12|pfx|jks|crt)$/i, "Credential material", "Security gate blocks. This should not enter a repository."],
  [/^\.env/i,                 "Environment file",     "Security gate blocks unless it is an example with no real values."],
  [/\.(png|jpe?g|svg|webp|gif)$/i, "Asset",           "Compliance gate applies: alt text and contrast."],
  [/\.(md|txt|rst)$/i,        "Document",             "Report & Documentation gate. Freshness will apply once REQ-CLI-006 lands."],
];

function classify(name){
  for(const [re, kind, note] of CLASSIFY) if(re.test(name)) return {kind, note};
  return {kind:"Unclassified", note:"Intake records unknowns as unknown rather than guessing a type."};
}

function proposeIntake(files){
  const rows = files.slice(0,40).map(f=>{
    const c = classify(f.name);
    const risky = /Credential|Environment/.test(c.kind);
    return `<tr><td class="k">${esc(f.name)}</td><td>${risky?"<b>":""}${esc(c.kind)}${risky?"</b>":""} · ${(f.size/1024).toFixed(1)} KB<br><span style="color:var(--marble-3);font-size:11.5px">${esc(c.note)}</span></td></tr>`;
  }).join("");
  const risky = files.filter(f=>/Credential|Environment/.test(classify(f.name).kind));

  const w = makeWindow("intake:"+Date.now(), {
    id: "Stage 01 · Intake — proposal",
    title: `${files.length} file${files.length===1?"":"s"} received`,
    hue: STAGE_SKIN["STAGE-01-INTAKE"].hue,
    width: 520, height: Math.min(560, innerHeight-140)
  });

  w.body.innerHTML = `
    <div class="blk"><h3>Classification</h3>
      <p>Intake records what arrived and how it classifies. It does not accept, move, or modify anything.</p></div>
    <div class="blk"><table>${rows}</table>
      ${files.length>40?`<p style="margin-top:10px">…and ${files.length-40} more.</p>`:""}</div>
    ${risky.length ? `<div class="note"><b>${risky.length} file${risky.length===1?"":"s"} would block at the Security gate.</b>
      Credential material and environment files fail before Build. If any value here is real, treat it as exposed and rotate it.</div>` : ""}
    <div class="note"><b>Nothing was read, uploaded, or written.</b>
      Only file names and sizes were inspected, in your browser. The pipeline does not advance from this window — a person decides.
      Run <code>aeos check</code> to produce a real report.</div>`;
}

/* ─────────── boot ─────────── */
resize();
ingest(REPORT);
buildVoxels();
requestAnimationFrame(frame);

// prefer a live report when served over http
fetch("report.json",{cache:"no-store"})
  .then(r=>r.ok?r.json():Promise.reject())
  .then(r=>{ ingest(r); buildVoxels(); })
  .catch(()=>{});
</script>
</body>
</html>
