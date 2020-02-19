load(DIR+'/../.mongocolorize.js');
function trafficlight(n) {
	if (n < 10) return green(n);
	if (n < 30) return yellow(n);
	return red(n);
}
db.currentOp({ "secs_running": { $gt: 1 }, "ns": { $not: /local/ } }).inprog.sort((a,b)=>a.secs_running-b.secs_running).forEach((o,i)=>{print(`${trafficlight(i)}> ${o.desc} ${o.ns} (${o.op}:${o.secs_running}) => ${JSON.stringify(o.query)}`)})
