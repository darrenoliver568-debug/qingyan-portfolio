document.addEventListener('DOMContentLoaded',()=>{
  const style=document.createElement('link');style.rel='stylesheet';style.href='assets/css/final.css';document.head.appendChild(style);
  const b=document.querySelector('.menu-btn'),n=document.querySelector('.nav-links');
  if(b&&!b.hasAttribute('aria-label'))b.setAttribute('aria-label','打开导航');
  b?.addEventListener('click',()=>{const open=n.classList.toggle('open');b.setAttribute('aria-expanded',String(open))});
  document.querySelector('.brand')?.replaceChildren(document.createTextNode('青砚｜朱青'));
  const page=location.pathname.split('/').pop()||'index.html';
  const nav=[['商业项目','index.html#work'],['叙事影像','films.html'],['漫剧经历','practice.html'],['关于我','about.html']];
  if(n){n.innerHTML=nav.map(([label,href])=>{const current=(page==='index.html'&&href.includes('#work'))||(page==='films.html'&&href==='films.html')||(page==='practice.html'&&href==='practice.html')||(page==='about.html'&&href==='about.html');return '<a '+(current?'aria-current="page" ':'')+'href="'+href+'">'+label+'</a>'}).join('')}
  document.querySelectorAll('img').forEach(img=>{img.decoding='async';if(img.closest('.hero-media,.cover')||img.classList.contains('zoomable'))img.loading='eager'});
  document.querySelectorAll('.zoomable').forEach(img=>img.addEventListener('click',()=>{const l=document.querySelector('.lightbox');if(!l)return;l.querySelector('img').src=img.src;l.classList.add('open')}));
  document.querySelector('.lightbox button')?.addEventListener('click',()=>document.querySelector('.lightbox').classList.remove('open'));
  document.querySelector('.lightbox')?.addEventListener('click',e=>{if(e.target.classList.contains('lightbox'))e.target.classList.remove('open')});
  document.querySelectorAll('[data-year]').forEach(e=>e.textContent=new Date().getFullYear());
  const base='https://github.com/darrenoliver568-debug/qingyan-portfolio/releases/download/v1-assets/';
  document.querySelectorAll('video source[src^="assets/video/"]').forEach(source=>{source.src=base+source.getAttribute('src').split('/').pop();source.parentElement.load()});
  document.querySelectorAll('video').forEach(v=>{const toggle=()=>v.paused?v.play():v.pause();if(v.closest('.vertical-video-card')){v.addEventListener('click',toggle);v.addEventListener('keydown',e=>{if(e.key==='Enter'||e.key===' '){e.preventDefault();toggle()}})}v.addEventListener('playing',()=>v.closest('.vertical-video-card')?.classList.add('is-playing'));v.addEventListener('pause',()=>v.closest('.vertical-video-card')?.classList.remove('is-playing'));v.addEventListener('error',()=>v.parentElement.querySelector('.error-message')?.classList.add('show'))});
  const swaps=[['NESCAFÉ','雀巢十五倍浓缩咖啡'],['AIGC Commercial Visual & Motion Portfolio','商业视觉作品集'],['AI 短剧生产实践','漫剧制作经历'],['AI 短剧','漫剧']];
  document.querySelectorAll('h1,h2,h3,p,span,strong,small').forEach(el=>{swaps.forEach(([from,to])=>{if(el.textContent.trim()===from)el.textContent=to})});
  document.querySelectorAll('.project-nav strong').forEach(el=>{el.textContent=el.textContent.replace('ILLY','意利咖啡').replace('NESCAFÉ','雀巢十五倍浓缩咖啡')});
  const footerLead=document.querySelector('.footer-inner>span:first-child');if(footerLead)footerLead.textContent='© '+new Date().getFullYear()+' 朱青';
});
