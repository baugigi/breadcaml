#!/usr/bin/env python3
"""vrun.py PRG RAWLOG [timeout_s]
Esegue il PRG in VICE (warp) tracciando le chiamate a CHROUT ($F1CA) con il monitor
(test_init.mon: log su file, stop al ritorno al BASIC, quit). La traccia e' raccolta in due modi:
 - dal file di log del monitor (-monlogname), completo se VICE esce da solo;
 - dallo stdout di VICE (senza buffering), che permette di fermare VICE appena compare il verdetto
   anche quando 'quit' non viene eseguito (VICE senza display, hang del monitor).
RAWLOG riceve la traccia completa disponibile. Il test termina al verdetto ("<etichetta> OK|FAIL"),
al termine di VICE, dopo STALL secondi senza nuove tracce, oppure al timeout.
Variabili: X64 (default x64sc), VICE_OPTS (opzioni extra), STALL (default 90)."""
import subprocess,sys,time,os,signal,re,select,shlex,shutil,tempfile
here=os.path.dirname(os.path.abspath(__file__))
prg,raw=sys.argv[1],sys.argv[2]; tmo=int(sys.argv[3]) if len(sys.argv)>3 else 300
STALL=int(os.environ.get('STALL','90'))
x64=os.environ.get('X64','x64sc'); extra=shlex.split(os.environ.get('VICE_OPTS',''))
mon=os.path.join(here,'test_init.mon'); dec=os.path.join(here,'decode_trace.py')
mlog=raw+'.monlog'; sout=raw+'.stdout'
for f in (mlog,sout,raw,raw+".vice"):
    if os.path.exists(f): os.remove(f)
cmd=[x64,'-warp']+extra+['-autostart',prg,'-moncommands',mon,'-monlogname',mlog]
if shutil.which('stdbuf'): cmd=['stdbuf','-o0','-e0']+cmd
# ogni istanza di VICE crea il disco di autostart in ~/.cache/vice: con piu' istanze in parallelo
# (run_tests.sh -j N) si pesterebbero a vicenda, quindi la cache e' privata per ogni esecuzione
cache=tempfile.mkdtemp(prefix='vrun-cache-')
env=dict(os.environ, XDG_CACHE_HOME=cache)
p=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,start_new_session=True,env=env)
V=re.compile(r'^([A-Za-z0-9_]+ (OK|FAIL)|FAILED)$',re.M)
def decoded(path):
    try: return subprocess.run([sys.executable,'-I',dec,path],capture_output=True,text=True).stdout.replace('\r','\n')
    except Exception: return ''
full=open(raw+'.vice','w'); out=open(sout,'w'); t0=time.time(); lastnew=t0; buf=b''; found=False; fd=p.stdout.fileno(); eof=False
while time.time()-t0<tmo and not found:
    r,_,_=select.select([fd],[],[],2)
    if r:
        d=os.read(fd,65536)
        if not d: eof=True
        else:
            full.write(d.decode('latin-1')); full.flush()
            buf+=d; *lines,buf=buf.split(b'\n'); new=0
            for l in lines:
                l=l.decode('latin-1')
                if l.startswith('Monitor: '): l=l[9:]
                if '.C:f1ca' in l or l.startswith('TRACE'): out.write(l+'\n'); new+=1
            if new:
                out.flush(); lastnew=time.time()
                if V.search(decoded(sout)): found=True; time.sleep(1)
    if eof or p.poll() is not None: break
    if time.time()-lastnew>STALL: break
exited = p.poll() is not None
try: os.killpg(p.pid,signal.SIGKILL)
except Exception: pass
out.close(); full.close()
# traccia finale: il log del monitor se VICE e' uscito da solo (completo), altrimenti lo stdout
src=sout
if exited and os.path.exists(mlog) and os.path.getsize(mlog)>0 and V.search(decoded(mlog)): src=mlog
elif os.path.exists(mlog) and os.path.getsize(mlog)>os.path.getsize(sout): src=mlog
shutil.copyfile(src,raw)
if V.search(decoded(raw)) and os.path.exists(raw+'.vice'): os.remove(raw+'.vice')   # l'output completo di VICE resta solo se manca il verdetto
for f in (mlog,sout):
    if os.path.exists(f): os.remove(f)
shutil.rmtree(cache,ignore_errors=True)
