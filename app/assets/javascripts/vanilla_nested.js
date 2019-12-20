(function(){
  // Get the html from the data attribute and insert the new fields on the container
  // "event" is the click event of the link created by the rails helper
  window.addVanillaNestedFields = function(event) {
    event.preventDefault();

    const element = event.target;
    const data = element.dataset;
    const container = document.querySelector(data.containerSelector);
    const newHtml = data.html.replace(/_idx_placeholder_/g, Date.now());

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

    _dispatchEvent(container, 'vanilla-nested:fields-added', element, {added: inserted})

    let removeLink = inserted.querySelector('.vanilla-nested-remove');
    if (removeLink)
      removeLink.addEventListener('click', removeVanillaNestedFields);

    // dispatch an event if we reached the limit configured on the model
    if (data.limit) {
      let nestedElements = container.children.length;
      if (nestedElements >= data.limit)
        _dispatchEvent(container, 'vanilla-nested:fields-limit-reached', element)
    }
  }

  // Removes the fields or hides them until the undo timer times out
  // "event" is the click event of the link created by the rails helper
  window.removeVanillaNestedFields = function(event) {
    event.preventDefault();

    const element = event.target;
    const data = element.dataset;
    let wrapper = element.parentElement;
    if (sel = data.fieldsWrapperSelector) wrapper = element.closest(sel);

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
    wrapper.style.display = 'none';
  }

  // Unhides the children given a fields wrapper
  // "wrapper" is the wrapper of the link to remove fields
  function unhideFields(wrapper) {
    [...wrapper.children].forEach(child => child.style.display = 'initial');
  }

  // Hides an element and adds an "undo" link to unhide it
  // "wrapper" is the wrapper to hide
  // "element" is the link to remove the wrapper
  function hideFieldsWithUndo(wrapper, element) {
    [...wrapper.children].forEach(child => child.style.display = 'none');

    // add the 'undo' link with it's callback
    const undoLink = _createUndoWithElementsData(element.dataset);
    wrapper.appendChild(undoLink);

    const _onUndoClicked = function(e) {
      e.preventDefault();
      clearTimeout(timer);
      unhideFields(wrapper);
      wrapper.querySelector('[name$="[_destroy]"]').value = '0';
      _dispatchEvent(wrapper, 'vanilla-nested:fields-hidden-undo', undoLink);
      undoLink.remove();
    }

    undoLink.addEventListener('click', _onUndoClicked);

    // start the timer
    const _onTimerCompleted = function() {
      hideWrapper(wrapper);
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
    if (classes = data.undoLinkClasses)
      undo.classList.add(...classes.split(' '));

    undo.innerText = data.undoText;

    return undo;
  }

  document.addEventListener('DOMContentLoaded', function(){
    document.querySelectorAll('.vanilla-nested-add').forEach(el => {
      el.addEventListener('click', addVanillaNestedFields);
    })

    document.querySelectorAll('.vanilla-nested-remove').forEach(el => {
      el.addEventListener('click', removeVanillaNestedFields);
    })
  })
})()
