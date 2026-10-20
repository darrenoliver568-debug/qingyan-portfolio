document.addEventListener('DOMContentLoaded',()=>{
  const b=document.querySelector('.menu-btn'),n=document.querySelector('.nav-links');
  if(b&&!b.hasAttribute('aria-label'))b.setAttribute('aria-label','打开导航');
  b?.addEventListener('click',()=>{const open=n.classList.toggle('open');b.setAttribute('aria-expanded',String(open))});
  document.querySelector('.brand')?.replaceChildren(document.createTextNode('青砚｜朱青'));
  const page=location.pathname.split('/').pop()||'index.html';
  const nav=[['商业项目','index.html#work'],['叙事影像','films.html'],['漫剧经历','practice.html'],['关于我','about.html']];
  if(n){n.innerHTML=nav.map(([label,href])=>{const current=(page==='index.html'&&href.includes('#work'))||(page==='films.html'&&href==='films.html')||(page==='practice.html'&&href==='practice.html')||(page==='about.html'&&href==='about.html');return '<a '+(current?'aria-current="page" ':'')+'href="'+href+'">'+label+'</a>'}).join('')}
  const lightbox=document.querySelector('.lightbox');
  const closeLightbox=()=>{if(!lightbox)return;lightbox.classList.remove('open');document.body.style.overflow=''};
  document.querySelectorAll('.zoomable').forEach(img=>img.addEventListener('click',()=>{if(!lightbox)return;lightbox.querySelector('img').src=img.src;lightbox.classList.add('open');document.body.style.overflow='hidden'}));
  lightbox?.querySelector('button')?.addEventListener('click',closeLightbox);
  lightbox?.addEventListener('click',e=>{if(e.target===lightbox)closeLightbox()});
  document.addEventListener('keydown',e=>{if(e.key==='Escape'&&lightbox?.classList.contains('open'))closeLightbox()});
  document.querySelectorAll('[data-year]').forEach(e=>e.textContent=new Date().getFullYear());
  const videos=[...document.querySelectorAll('video')];
  const warmVideo=v=>{if(v.dataset.warmed)return;v.dataset.warmed='true';v.load()};
  if('IntersectionObserver'in window){const observer=new IntersectionObserver(entries=>entries.forEach(entry=>{if(entry.isIntersecting){warmVideo(entry.target);observer.unobserve(entry.target)}}),{rootMargin:'600px 0px'});videos.forEach(v=>observer.observe(v))}else{videos.forEach(warmVideo)}
  videos.forEach(v=>{const vertical=Boolean(v.closest('.vertical-video-card'));const ready=()=>v.classList.add('is-ready');if(v.readyState>=2)ready();else v.addEventListener('canplay',ready,{once:true});if(vertical){const toggle=()=>{warmVideo(v);v.paused?v.play().catch(()=>{}):v.pause()};v.addEventListener('click',toggle);v.addEventListener('keydown',e=>{if(e.key==='Enter'||e.key===' '){e.preventDefault();toggle()}})}v.addEventListener('playing',()=>v.closest('.vertical-video-card')?.classList.add('is-playing'));v.addEventListener('pause',()=>v.closest('.vertical-video-card')?.classList.remove('is-playing'));v.addEventListener('error',()=>v.parentElement.querySelector('.error-message')?.classList.add('show'))});
  const swaps=[['NESCAFÉ','雀巢十五倍浓缩咖啡'],['AIGC Commercial Visual & Motion Portfolio','商业视觉作品集'],['AI 短剧生产实践','漫剧制作经历'],['AI 短剧','漫剧']];
  document.querySelectorAll('h1,h2,h3,p,span,strong,small').forEach(el=>{swaps.forEach(([from,to])=>{if(el.textContent.trim()===from)el.textContent=to})});
  document.querySelectorAll('.project-nav strong').forEach(el=>{el.textContent=el.textContent.replace('ILLY','意利咖啡').replace('NESCAFÉ','雀巢十五倍浓缩咖啡')});
  const footerLead=document.querySelector('.footer-inner>span:first-child');if(footerLead)footerLead.textContent='© '+new Date().getFullYear()+' 朱青';
});
