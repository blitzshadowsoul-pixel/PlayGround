#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
PROJECT_ROOT="$(pwd)"
/usr/bin/time -p pwd
PORT="${PORT:-3000}"
export PORT
/usr/bin/time -p bash -c 'echo "starting static server"'
# Keep source + built output inside PROJECT_DIR; metadata only in OPENCODE_WEB_DIR/RUNNER_TEMP.
/usr/bin/time -p mkdir -p "$PROJECT_ROOT/dist"
/usr/bin/time -p cp -f "$PROJECT_ROOT/pirate-rpg-game/index.html" "$PROJECT_ROOT/dist/index.html"
/usr/bin/time -p test -f "$PROJECT_ROOT/dist/index.html"
/usr/bin/time -p ls -la "$PROJECT_ROOT/dist"
/usr/bin/time -p bash -c 'if [ -f package.json ]; then if [ -f package-lock.json ]; then npm ci --no-audit --no-fund; else npm install --no-audit --no-fund; fi; if node -e "const p=require(\"./package.json\");process.exit(p.scripts&&p.scripts.build?0:1)"; then npm run build; fi; else echo "no package.json, static build only"; fi'
WEB_DIR="${OPENCODE_WEB_DIR:-/home/runner/work/_temp/omgithub-web}"
/usr/bin/time -p mkdir -p "$WEB_DIR"
/usr/bin/time -p node -e 'const fs=require("fs"),path=require("path");const webDir=process.env.OPENCODE_WEB_DIR||"/home/runner/work/_temp/omgithub-web";const project=process.cwd();const dir=path.resolve(project,"dist");if(!fs.existsSync(path.join(dir,"index.html")))throw new Error("dist/index.html missing");fs.mkdirSync(webDir,{recursive:true});fs.writeFileSync(path.join(webDir,"deployment-output.json"),JSON.stringify({project,directory:dir}));console.log("deployment-output:",JSON.stringify({project,directory:dir}));'
/usr/bin/time -p cat "$WEB_DIR/deployment-output.json"
echo "Serving $PROJECT_ROOT/dist on PORT $PORT (foreground)"
/usr/bin/time -p node -e '
const http=require("http"),fs=require("fs"),path=require("path");
const root=path.resolve(process.cwd(),"dist");
const port=Number(process.env.PORT||3000);
const mime={".html":"text/html",".js":"application/javascript",".css":"text/css",".json":"application/json",".svg":"image/svg+xml",".png":"image/png",".jpg":"image/jpeg",".webp":"image/webp",".wasm":"application/wasm"};
const server=http.createServer((req,res)=>{
  try{
    const url=new URL(req.url,"http://localhost");
    let p=path.normalize(path.join(root,decodeURIComponent(url.pathname)));
    if(p!==root&&!p.startsWith(root+path.sep)){res.writeHead(404);res.end("Not found");return;}
    let stat;try{stat=fs.statSync(p);}catch{res.writeHead(404);res.end("Not found");return;}
    if(stat.isDirectory())p=path.join(p,"index.html");
    const data=fs.readFileSync(p);
    res.setHeader("Content-Type",mime[path.extname(p)]||"application/octet-stream");
    res.setHeader("Cache-Control","no-cache");
    res.end(data);
  }catch(e){res.writeHead(404);res.end("Not found");}
});
server.listen(port,"0.0.0.0",()=>console.log("listening on "+port+" serving "+root));
'
