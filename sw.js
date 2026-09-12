var CACHE='eisenlink-v4';
var FILES=['./','./index.html','./three.min.js','./manifest.webmanifest','./icon-192.png','./icon-512.png'];
self.addEventListener('install',function(e){
  e.waitUntil(caches.open(CACHE).then(function(c){return c.addAll(FILES)}).then(function(){return self.skipWaiting()}));
});
self.addEventListener('activate',function(e){
  e.waitUntil(caches.keys().then(function(k){
    return Promise.all(k.map(function(n){return n===CACHE?null:caches.delete(n)}));
  }).then(function(){return self.clients.claim()}));
});
self.addEventListener('fetch',function(e){
  if(e.request.method!=='GET')return;
  // il documento: prima la rete (così gli aggiornamenti arrivano subito), cache come riserva
  if(e.request.mode==='navigate'){
    e.respondWith(fetch(e.request).then(function(res){
      var copy=res.clone();
      caches.open(CACHE).then(function(c){c.put('./index.html',copy)}).catch(function(){});
      return res;
    }).catch(function(){return caches.match('./index.html')}));
    return;
  }
  // tutto il resto: prima la cache
  e.respondWith(caches.match(e.request).then(function(r){
    return r||fetch(e.request).then(function(res){
      var copy=res.clone();
      caches.open(CACHE).then(function(c){c.put(e.request,copy)}).catch(function(){});
      return res;
    });
  }));
});
