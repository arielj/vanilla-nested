// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import "controllers";

import "vanilla-nested";

document.addEventListener("vanilla-nested:fields-limit-reached", () => {
  document
    .getElementById("pets")
    .insertAdjacentHTML("afterbegin", "<span>Limit reached</span>");
});
