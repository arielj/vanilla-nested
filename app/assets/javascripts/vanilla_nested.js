(function(){
  // Get the html from the data attribute and insert the new fields on the container
  // "event" is the click event of the link created by the rails helper
  window.addVanillaNestedFields = function(element) {
    if (!element.classList.contains('vanilla-nested-add'))
      element = element.closest('.vanilla-nested-add')

    const data = element.dataset;
    const container = document.querySelector(data.containerSelector);
    const newHtml = data.html.replace(/_idx_placeholder_/g, Date.now());

    // insert and store reference
    let inserted;
    switch (data.methodForInsert) {
      case ('append'):
        container.insertAdjacentHTML('beforeend', newHtml);
        inserted = container.lastElementChild;
        break;
      case ('prepend'):
        container.insertAdjacentHTML('afterbegin', newHtml);
        inserted = container.firstElementChild;
        break;
    }

    // add a class to show it was added dynamically
    inserted.classList.add('added-by-vanilla-nested');

    _dispatchEvent(container, 'vanilla-nested:fields-added', element, {added: inserted})

    // dispatch an event if we reached the limit configured on the model
    if (data.limit) {
      let nestedElements = container.querySelectorAll('[name$="[_destroy]"][value="0"]').length;
      if (nestedElements >= data.limit)
        _dispatchEvent(container, 'vanilla-nested:fields-limit-reached', element)
    }
  }

  // Removes the fields or hides them until the undo timer times out
  // "event" is the click event of the link created by the rails helper
  window.removeVanillaNestedFields = function(element) {
    if (!element.classList.contains('vanilla-nested-remove'))
      element = element.closest('.vanilla-nested-remove')

    const data = element.dataset;
    let wrapper = element.parentElement;
    const sel = data.fieldsWrapperSelector;
    if (sel) wrapper = element.closest(sel);

    if (data.undoTimeout) {
      hideFieldsWithUndo(wrapper, element);
      _dispatchEvent(wrapper, 'vanilla-nested:fields-hidden', element);
    } else {
      hideWrapper(wrapper);
      unhideFields(wrapper);
      _dispatchEvent(wrapper, 'vanilla-nested:fields-removed', element);
    }
    wrapper.querySelector('[name$="[_destroy]"]').value = '1';
  }

  // Hides an element, mainly the wrapper of a group of fields
  // "wrapper" is the wrapper of the link to remove fields
  function hideWrapper(wrapper) {
    if (wrapper.classList.contains('added-by-vanilla-nested')) {
      wrapper.remove();
    } else {
      wrapper.classList.add('removed-by-vanilla-nested');
      const destroyInput = wrapper.querySelector('[name$="[_destroy]"');
      wrapper.innerHTML = '';
      wrapper.insertAdjacentElement('afterbegin', destroyInput);
    }
  }

  // Unhides the children given a fields wrapper
  // "wrapper" is the wrapper of the link to remove fields
  function unhideFields(wrapper) {
    [...wrapper.children].forEach(child => {
      if (child.dataset.hasAttributeStyle) {
        child.style.display = child.dataset.originalDisplay;
      } else {
        child.removeAttribute("style");
      }
    });
  }

  // Hides an element and adds an "undo" link to unhide it
  // "wrapper" is the wrapper to hide
  // "element" is the link to remove the wrapper
  function hideFieldsWithUndo(wrapper, element) {
    wrapper.classList.add('hidden-by-vanilla-nested');
    [...wrapper.children].forEach(child => {
      // store original style for after undo
      if (child.getAttribute("style")) {
        child.dataset.hasAttributeStyle = true;
        child.dataset.originalDisplay = child.style.display;
      }

      child.style.display = 'none';
    });

    // add the 'undo' link with it's callback
    const undoLink = _createUndoWithElementsData(element.dataset);
    wrapper.appendChild(undoLink);

    const _onUndoClicked = function(e) {
      e.preventDefault();
      clearTimeout(timer);
      unhideFields(wrapper);
      wrapper.querySelector('[name$="[_destroy]"]').value = '0';
      wrapper.classList.remove('hidden-by-vanilla-nested');
      _dispatchEvent(wrapper, 'vanilla-nested:fields-hidden-undo', undoLink);
      undoLink.remove();
    }

    undoLink.addEventListener('click', _onUndoClicked);

    // start the timer
    const _onTimerCompleted = function() {
      hideWrapper(wrapper);
      wrapper.classList.remove('hidden-by-vanilla-nested');
      unhideFields(wrapper);
      _dispatchEvent(wrapper, 'vanilla-nested:fields-removed', undoLink);
      undoLink.remove();
    }

    let ms = element.dataset.undoTimeout;
    let timer = setTimeout(_onTimerCompleted, ms);
  }

  function _dispatchEvent(element, eventName, triggeredBy, details) {
    if (!details) details = {};
    details.triggeredBy = triggeredBy;

    let event = new CustomEvent(eventName, {bubbles: true, detail: details})
    element.dispatchEvent(event);
  }

  function _createUndoWithElementsData(data) {
    const undo = document.createElement('A');

    undo.classList.add('vanilla-nested-undo');
    const classes = data.undoLinkClasses;
    if (classes)
      undo.classList.add(...classes.split(' '));

    undo.innerText = data.undoText;

    return undo;
  }

  function initVanillaNested() {
    document.addEventListener('click', ev => {
      const addVanillaNested =
        ev.target.classList.contains('vanilla-nested-add') ||
        ev.target.closest('.vanilla-nested-add');

      if (addVanillaNested) {
        ev.preventDefault();
        addVanillaNestedFields(ev.target);
      }
    })

    document.addEventListener('click', ev => {
      const removeVanillaNested =
        ev.target.classList.contains('vanilla-nested-remove') ||
        ev.target.closest('.vanilla-nested-remove');

      if (removeVanillaNested) {
        ev.preventDefault();
        removeVanillaNestedFields(ev.target);
      }
    })
  }

  let vanillaNestedInitialized = false
  const initOnce = () => {
    if (!vanillaNestedInitialized) {
      vanillaNestedInitialized = true
      initVanillaNested()
    }
  }

  if (["complete", "interactive"].includes(document.readyState)) {
    // if DOMContentLoaded was already fired
    initOnce()
  } else {
    // else wait for it
    document.addEventListener("DOMContentLoaded", () => initOnce())
  }
})()
