document.addEventListener('click', function(e) {
  if (e.target.classList.contains('vanilla-nested-add')) {
    e.preventDefault();
    addVanillaNestedFields(e.target);
  }

  if (e.target.classList.contains('vanilla-nested-remove')) {
    e.preventDefault();
    removeVanillaNestedFields(e.target);
  }
})

addVanillaNestedFields = function(btn) {
  let html = btn.dataset.html.replace(/_idx_placeholder_/g, Date.now());
  let auxDiv = document.createElement('div');
  auxDiv.innerHTML = html;
  let toInsert = auxDiv.children[0];
  const container = document.querySelector(btn.dataset.containerSelector);
  if (btn.dataset.methodForInsert == 'append') container.appendChild(toInsert);
  else if (btn.dataset.methodForInsert == 'prepend') container.insertBefore(toInsert, container.children[0]);
}

removeVanillaNestedFields = function(btn) {
  const wrapper = btn.parentElement;
  wrapper.style.display = 'none';
  wrapper.querySelector('[name$="[_destroy]"]').value = '1';
}