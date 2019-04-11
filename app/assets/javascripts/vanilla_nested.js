(function(){
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

  function addVanillaNestedFields(btn) {
    const auxDiv = document.createElement('div');
    auxDiv.innerHTML = btn.dataset.html.replace(/_idx_placeholder_/g, Date.now());
    const toInsert = auxDiv.children[0];
    const container = document.querySelector(btn.dataset.containerSelector);
    if (btn.dataset.methodForInsert == 'append') container.appendChild(toInsert);
    else if (btn.dataset.methodForInsert == 'prepend') container.insertBefore(toInsert, container.children[0]);

    dispatchEvent(container, 'vanilla-nested:fields-added', btn, {added: toInsert})
  }

  function removeVanillaNestedFields(btn) {
    let wrapper = btn.parentElement;
    if (sel = btn.dataset.fieldsWrapperSelector) wrapper = btn.closest(sel);

    if (btn.dataset.undoTimeout) {
      hideFieldsWithUndo(wrapper, btn)
      dispatchEvent(wrapper, 'vanilla-nested:fields-hidden', btn);
    } else {
      hideWrapper(wrapper);
      dispatchEvent(wrapper, 'vanilla-nested:fields-removed', btn);
    }
    wrapper.querySelector('[name$="[_destroy]"]').value = '1';
  }

  function hideWrapper(wrapper) {
    wrapper.style.display = 'none';
    unhideFields(wrapper);
  }

  function unhideFields(wrapper) {
    [...wrapper.children].forEach(child => child.style.display = 'initial');
  }

  function hideFieldsWithUndo(wrapper, btn) {
    let ms = btn.dataset.undoTimeout;

    [...wrapper.children].forEach(child => child.style.display = 'none');

    const undoLink = document.createElement('A');
    undoLink.classList.add('vanilla-nested-undo');
    if (classes = btn.dataset.undoLinkClasses) undoLink.classList.add(...classes.split(' '));
    undoLink.innerText = btn.dataset.undoText;
    wrapper.appendChild(undoLink);

    let timer = setTimeout(function() {
      hideWrapper(wrapper)
      dispatchEvent(wrapper, 'vanilla-nested:fields-removed', undoLink);
      undoLink.remove();
    }, ms)

    undoLink.addEventListener('click', function(e){
      clearTimeout(timer);
      unhideFields(wrapper);
      wrapper.querySelector('[name$="[_destroy]"]').value = '0';
      dispatchEvent(wrapper, 'vanilla-nested:fields-hidden-undo', undoLink);
      undoLink.remove();
    })
  }

  function dispatchEvent(element, eventName, triggeredBy, details) {
    if (!details) details = {};
    details.triggeredBy = triggeredBy;

    let event = new CustomEvent(eventName, {bubbles: true, detail: details})
    element.dispatchEvent(event);
  }
})()