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

#creed{position:fixed;bottom:26px;left:50%;transform:translateX(-50%);z-index:6;
  text-align:center;pointer-events:none;width:min(94vw,760px)}
#creed .k{font-size:8.5px;letter-spacing:.44em;color:var(--gilt-dim)}
#creed .v{margin:9px 0 0;font-size:12px;font-style:italic;color:var(--marble-3)}

/* ── panels ── */
.panel{
  position:fixed;z-index:8;width:min(94vw,430px);
  background:linear-gradient(174deg,rgba(26,22,19,.97),rgba(15,13,11,.98));
  border:1px solid var(--edge);backdrop-filter:blur(11px);
  box-shadow:0 26px 70px rgba(0,0,0,.62);
  display:none;max-height:78vh;overflow-y:auto;overscroll-behavior:contain}
.panel.open{display:block}
.panel::-webkit-scrollbar{width:5px}
.panel::-webkit-scrollbar-thumb{background:var(--gilt-dim)}
#stagePanel{top:50%;right:30px;transform:translateY(-50%)}
#dropPanel{top:50%;left:50%;transform:translate(-50%,-50%);width:min(94vw,540px)}
.ph{padding:18px 22px;border-bottom:1px solid var(--edge-2);
  display:flex;justify-content:space-between;align-items:flex-start;gap:14px;
  position:sticky;top:0;background:rgba(15,13,11,.97);z-index:1}
.ph .id{font-size:8.5px;color:var(--gilt);margin:0 0 6px}
.ph h2{font-family:"Cinzel",serif;font-size:16px;font-weight:500;letter-spacing:.1em;margin:0;color:var(--marble)}
.x{background:none;border:1px solid var(--edge);color:var(--marble-3);
  width:26px;height:26px;flex:none;cursor:pointer;font-size:14px;line-height:1;font-family:inherit}
.x:hover{color:var(--marble);border-color:var(--gilt)}
.x:focus-visible{outline:2px solid var(--gilt);outline-offset:2px}
.pb{padding:18px 22px 24px}
.blk{margin:0 0 20px}
.blk:last-child{margin:0}
.blk>h3{font-size:8.5px;color:var(--gilt-dim);margin:0 0 9px;font-family:"IBM Plex Mono",monospace;
  letter-spacing:.2em;text-transform:uppercase;font-weight:500}
.blk p{margin:0;font-size:13.5px;line-height:1.75;color:var(--marble-2)}
.blk ol,.blk ul{margin:0;padding-left:17px;font-size:12.5px;line-height:1.85;color:var(--marble-2)}
.blk li{margin:0 0 4px}
.mem{border-left:2px solid var(--gilt-dim);padding:2px 0 2px 13px;margin:0 0 15px}
.mem .d{font-family:"IBM Plex Mono",monospace;font-size:8.5px;letter-spacing:.13em;color:var(--gilt-dim)}
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

#hint{position:fixed;bottom:74px;left:50%;transform:translateX(-50%);z-index:6;
  font-size:8.5px;letter-spacing:.24em;color:var(--marble-3);opacity:.62;pointer-events:none;
  font-family:"IBM Plex Mono",monospace;text-transform:uppercase;text-align:center}

@media (prefers-reduced-motion:reduce){#dropZone .ring{animation:none}}
@media (max-width:760px){
  #stagePanel{right:auto;left:50%;top:auto;bottom:0;transform:translateX(-50%);
    width:100vw;max-height:66vh;border-left:0;border-right:0;border-bottom:0}
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
  <p class="mono">Personal Engineering Command System</p>
</div>

<div id="hint" class="mono">Drag a file onto the globe to begin intake · Click a stage orb</div>

<div id="creed">
  <p class="k mono">Integrate · Orchestrate · Elevate</p>
  <p class="v">It reports what it knows, and says so when it does not.</p>
</div>

<div id="dropZone">
  <div class="msg"><div class="ring"></div>
    <h2>RELEASE TO BEGIN INTAKE</h2>
    <p>Nothing is written. AEOS will propose, not act.</p></div>
</div>

<section class="panel" id="stagePanel" role="dialog" aria-modal="false" aria-labelledby="spTitle">
  <div class="ph"><div><p class="id mono" id="spId"></p><h2 id="spTitle"></h2></div>
    <button class="x" id="spClose" aria-label="Close">×</button></div>
  <div class="pb" id="spBody"></div>
</section>

<section class="panel" id="dropPanel" role="dialog" aria-modal="false" aria-labelledby="dpTitle">
  <div class="ph"><div><p class="id mono">Intake · Proposal</p><h2 id="dpTitle">Received</h2></div>
    <button class="x" id="dpClose" aria-label="Close">×</button></div>
  <div class="pb" id="dpBody"></div>
</section>

<script>
const REPORT = __REPORT__;
const STAGES = __STAGES__;

const NAMES = {
 "STAGE-01-INTAKE":"Intake","STAGE-02-DESIGN":"Design","STAGE-03-BUILD":"Build",
 "STAGE-04-QA":"QA","STAGE-05-SECURITY":"Security","STAGE-06-COMPLIANCE":"Compliance",
 "STAGE-07-RELEASE":"Release","STAGE-08-REPORT":"Report"};
const TYPE_COLOR = {REQ:[201,162,39],ADR:[126,144,104],STAGE:[232,203,114],
  AUDIT:[180,87,58],PROJECT:[232,224,210],STATUS:[189,178,160]};

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
let mx=-9e9, my=-9e9, hoverOrb=-1, breathing=0, dropping=false;
const calm = matchMedia("(prefers-reduced-motion: reduce)").matches;

function resize(){
  DPR = Math.min(devicePixelRatio||1, 2);
  W = innerWidth; H = innerHeight;
  cv.width = W*DPR; cv.height = H*DPR;
  cv.style.width = W+"px"; cv.style.height = H+"px";
  ctx.setTransform(DPR,0,0,DPR,0,0);
  cx = W/2; cy = H*0.435;
  R = Math.min(W*0.19, H*0.29, 250);
}
addEventListener("resize", resize);

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
  ids.forEach((id,i)=>ORBS.push({id, name:NAMES[id]||id, i, a:0, x:0, y:0, r:0, glow:0}));
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
  if(!calm){ tYaw += .0016; breathing = Math.sin(t/1750)*.5+.5; }

  yaw   += (tYaw   - yaw)   * .05;
  pitch += (tPitch - pitch) * .06;

  const sy=Math.sin(yaw), cyaw=Math.cos(yaw), sp=Math.sin(pitch), cp=Math.cos(pitch);
  const rad = R * (1 + breathing*.012 + (dropping?.075:0));

  drawPlatform(rad);

  /* halo */
  const halo = ctx.createRadialGradient(cx,cy,rad*.55,cx,cy,rad*2.15);
  halo.addColorStop(0,`rgba(232,203,114,${.15+breathing*.05+(dropping?.14:0)})`);
  halo.addColorStop(1,"rgba(232,203,114,0)");
  ctx.fillStyle=halo; ctx.beginPath(); ctx.arc(cx,cy,rad*2.15,0,7); ctx.fill();

  /* voxels */
  const pts = [];
  for(const v of VOX){
    const p = project(v, sy, cyaw, sp, cp);
    const persp = 1/(1 + p.z*.34);
    const sx = cx + p.x*rad*persp, syy = cy + p.y*rad*persp;
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
    const nx = p.sx + (p.sx-cx)*off/rad, ny = p.syy + (p.syy-cy)*off/rad;
    ctx.fillStyle = `rgba(${Math.min(255,r+boost*150)|0},${Math.min(255,g+boost*130)|0},${Math.min(255,b+boost*80)|0},${Math.min(1,shade+boost*.55)})`;
    ctx.fillRect(nx-sz/2, ny-sz/2, sz, sz);
  }

  /* light shaft to the floor */
  const shaft = ctx.createLinearGradient(cx,cy+rad*.55,cx,cy+rad*1.9);
  shaft.addColorStop(0,`rgba(232,203,114,${.3+breathing*.09})`);
  shaft.addColorStop(1,"rgba(232,203,114,0)");
  ctx.fillStyle=shaft;
  ctx.beginPath(); ctx.moveTo(cx-rad*.10,cy+rad*.5);
  ctx.lineTo(cx+rad*.10,cy+rad*.5); ctx.lineTo(cx+rad*.62,cy+rad*1.9);
  ctx.lineTo(cx-rad*.62,cy+rad*1.9); ctx.closePath(); ctx.fill();

  drawOrbs(rad, t);
  requestAnimationFrame(frame);
}

function drawPlatform(rad){
  const py = cy + rad*1.34, rx = rad*2.55, ry = rad*.55;
  ctx.save();
  ctx.strokeStyle="rgba(201,162,39,.2)"; ctx.lineWidth=1;
  for(let k=1;k<=3;k++){
    ctx.beginPath(); ctx.ellipse(cx,py,rx*(.52+k*.17),ry*(.52+k*.17),0,0,7); ctx.stroke();
  }
  const fl = ctx.createRadialGradient(cx,py,0,cx,py,rx);
  fl.addColorStop(0,"rgba(232,224,210,.075)"); fl.addColorStop(1,"rgba(232,224,210,0)");
  ctx.fillStyle=fl; ctx.beginPath(); ctx.ellipse(cx,py,rx,ry,0,0,7); ctx.fill();
  ctx.restore();
}

function drawOrbs(rad, t){
  const py = cy + rad*1.34, rx = rad*2.02, ry = rad*.46;
  const n = ORBS.length || 8;
  ORBS.forEach((o,i)=>{
    const a = Math.PI + (i+.5)*(Math.PI/n);      // front arc, left to right
    o.x = cx + Math.cos(a)*rx;
    o.y = py + Math.sin(a)*ry;
    const isActive = o.id === activeStage, isOpen = o.id === openStage;
    const target = (isActive?1:0) + (i===hoverOrb?.55:0) + (isOpen?.5:0);
    o.glow += (Math.min(1.6,target) - o.glow)*.12;
    o.r = rad*.108 * (1 + o.glow*.2);

    // aura
    if(o.glow>.02){
      const g = ctx.createRadialGradient(o.x,o.y,0,o.x,o.y,o.r*3.6);
      g.addColorStop(0,`rgba(232,203,114,${.34*o.glow})`);
      g.addColorStop(1,"rgba(232,203,114,0)");
      ctx.fillStyle=g; ctx.beginPath(); ctx.arc(o.x,o.y,o.r*3.6,0,7); ctx.fill();
    }
    // voxel shell
    const seed = i*17.3, pulse = isActive && !calm ? Math.sin(t/520+i)*.14+.86 : 1;
    for(let k=0;k<46;k++){
      const yy = 1-(k/45)*2, rr = Math.sqrt(Math.max(0,1-yy*yy));
      const th = 2.399*k + seed + (calm?0:t/2600);
      const px = Math.cos(th)*rr, pz = Math.sin(th)*rr;
      if(pz < -.15) continue;
      const s = Math.max(1.1, o.r*.3*(1+pz*.3));
      const lum = (.3 + o.glow*.62) * (.55+pz*.45) * pulse;
      ctx.fillStyle = `rgba(232,203,114,${Math.min(.95,lum)})`;
      ctx.fillRect(o.x+px*o.r-s/2, o.y+yy*o.r-s/2, s, s);
    }
    // ring for the declared stage
    if(isActive){
      ctx.strokeStyle=`rgba(232,203,114,${.34+ (calm?0:Math.sin(t/620)*.16)})`;
      ctx.lineWidth=1; ctx.beginPath(); ctx.arc(o.x,o.y,o.r*1.85,0,7); ctx.stroke();
    }
    // label
    ctx.font = `${i===hoverOrb||isActive?"500":"400"} 9px "IBM Plex Mono",monospace`;
    ctx.textAlign="center";
    ctx.fillStyle = isActive ? "rgba(232,203,114,.95)"
                  : i===hoverOrb ? "rgba(232,224,210,.9)" : "rgba(138,128,115,.72)";
    ctx.fillText(String(i+1).padStart(2,"0")+"  "+o.name.toUpperCase(), o.x, o.y+o.r*2.5+11);
  });
}

/* ─────────── interaction ─────────── */
addEventListener("pointermove", e => {
  mx = e.clientX; my = e.clientY;
  tYaw   += ((e.clientX/W - .5) * .0009);
  tPitch = -.16 + (e.clientY/H - .5) * .30;
  let h = -1;
  ORBS.forEach((o,i)=>{ if(Math.hypot(e.clientX-o.x, e.clientY-o.y) < o.r*2.1) h=i; });
  if(h!==hoverOrb){ hoverOrb=h; cv.style.cursor = h>=0 ? "pointer" : "default"; }
});
addEventListener("pointerleave", ()=>{ mx=my=-9e9; });
cv.addEventListener("click", e => {
  const hit = ORBS.find(o => Math.hypot(e.clientX-o.x, e.clientY-o.y) < o.r*2.1);
  if(hit) showStage(hit.id);
});
addEventListener("keydown", e => {
  if(e.key === "Escape"){ closePanels(); return; }
  const n = parseInt(e.key,10);
  if(n>=1 && n<=8 && ORBS[n-1]) showStage(ORBS[n-1].id);
});

function closePanels(){
  $("stagePanel").classList.remove("open");
  $("dropPanel").classList.remove("open");
  openStage = null;
}
$("spClose").onclick = closePanels;
$("dpClose").onclick = closePanels;

function showStage(id){
  const s = STAGES[id];
  const rec = (report.records||[]).find(r=>r.id===id);
  openStage = id;
  $("spId").textContent = id + (rec?.status ? " · " + rec.status : "");
  $("spTitle").textContent = NAMES[id] || id;

  const isActive = id === activeStage;
  let html = "";

  html += `<div class="blk"><span class="tag ${isActive?"on":"unk"}">${isActive?"Declared current stage":"Not the declared stage"}</span></div>`;

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
    if(s.memory?.length)
      html += `<div class="blk"><h3>Memory · ${s.memory.length} entr${s.memory.length===1?"y":"ies"}</h3>` +
        s.memory.map(m=>`<div class="mem"><p class="d">${esc(m.date)}</p><p class="t">${esc(m.title)}</p><p class="b">${esc(m.body)}</p></div>`).join("") + `</div>`;
  }

  // stage-relevant findings, straight from the report
  const rel = (report.findings||[]).filter(f =>
    id==="STAGE-05-SECURITY" ? /SEC/.test(f.rule) : id==="STAGE-08-REPORT" ? /VER|DOC/.test(f.rule) : false);
  html += `<div class="blk"><h3>Findings at this gate</h3>` +
    (rel.length ? `<table>${rel.map(f=>`<tr><td class="k">${esc(f.severity)}</td><td>${esc(f.message)}</td></tr>`).join("")}</table>`
                : `<p>None reported. AEOS surfaces findings for the Security and Report gates; the other six have no automated check yet, so their state is unknown rather than passing.</p>`) + `</div>`;

  if(rec) html += `<div class="blk"><h3>Record</h3><p><code>${esc(rec.path)}</code></p></div>`;

  $("spBody").innerHTML = html;
  $("dropPanel").classList.remove("open");
  $("stagePanel").classList.add("open");
  $("spClose").focus();
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

  $("dpTitle").textContent = `${files.length} file${files.length===1?"":"s"} received`;
  $("dpBody").innerHTML = `
    <div class="blk"><h3>Stage 01 · Intake — classification</h3>
      <p>Intake records what arrived and how it classifies. It does not accept, move, or modify anything.</p></div>
    <div class="blk"><table>${rows}</table>
      ${files.length>40?`<p style="margin-top:10px">…and ${files.length-40} more.</p>`:""}</div>
    ${risky.length ? `<div class="note"><b>${risky.length} file${risky.length===1?"":"s"} would block at the Security gate.</b>
      Credential material and environment files fail before Build. If any value here is real, treat it as exposed and rotate it.</div>` : ""}
    <div class="note"><b>Nothing was read, uploaded, or written.</b>
      Only file names and sizes were inspected, in your browser. The pipeline does not advance from this window — a person decides.
      Run <code>aeos check</code> to produce a real report.</div>`;
  $("stagePanel").classList.remove("open");
  $("dropPanel").classList.add("open");
  $("dpClose").focus();
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
