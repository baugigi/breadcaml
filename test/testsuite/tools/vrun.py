#!/usr/bin/env python3
"""vrun.py PRG RAWLOG [timeout_s]
Esegue il PRG in VICE (warp) tracciando le chiamate a CHROUT ($F1CA) con il monitor; la traccia
(letta da stdout, senza buffering) viene salvata in RAWLOG e decodificata con decode_trace.py.
Termina appena compare il verdetto ("<etichetta> OK|FAIL"), oppure dopo STALL secondi senza
nuove tracce, oppure al timeout. Variabili: X64 (default x64sc), VICE_OPTS, STALL (default 90)."""
import subprocess,sys,time,os,signal,re,select,shlex,tempfile
here=os.path.dirname(os.path.abspath(__file__))
prg,raw=sys.argv[1],sys.argv[2]; tmo=int(sys.argv[3]) if len(sys.argv)>3 else 300
STALL=int(os.environ.get('STALL','90'))
x64=os.environ.get('X64','x64sc'); extra=shlex.split(os.environ.get('VICE_OPTS',''))
mon=os.path.join(here,'test_init.mon')
# la traccia va su stdout del monitor: servono solo "trace f1ca" e "g"
cmds=[l for l in open(mon) if not l.startswith(('log ','command','ignore','break'))]
tf=tempfile.NamedTemporaryFile('w',suffix='.mon',delete=False); tf.writelines(cmds); tf.close()
cmd=['stdbuf','-o0','-e0',x64,'-warp']+extra+['-autostart',prg,'-moncommands',tf.name]
p=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,start_new_session=True)
V=re.compile(r'^[A-Za-z0-9_]+ (OK|FAIL)$',re.M)
dec=os.path.join(here,'decode_trace.py')
out=open(raw,'w'); t0=time.time(); lastnew=t0; buf=b''; n=0; found=False
fd=p.stdout.fileno()
while time.time()-t0<tmo and p.poll() is None and not found:
    r,_,_=select.select([fd],[],[],2)
    if r:
        d=os.read(fd,65536)
        if not d: break
        buf+=d
        *lines,buf=buf.split(b'\n')
        new=0
        for l in lines:
            l=l.decode('latin-1')
            if l.startswith('Monitor: '): l=l[9:]
            if '.C:f1ca' in l or l.startswith('TRACE'):
                out.write(l+'\n'); new+=1
        if new:
            out.flush(); lastnew=time.time(); n+=new
            if n%20==0 or True:
                txt=subprocess.run([sys.executable,'-I',dec,raw],capture_output=True,text=True).stdout.replace('\r','\n')
                if V.search(txt): found=True; time.sleep(1)
    if time.time()-lastnew>STALL: break
try: os.killpg(p.pid,signal.SIGKILL)
except Exception: pass
out.close(); os.unlink(tf.name)
