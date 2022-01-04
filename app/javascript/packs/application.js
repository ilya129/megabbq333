// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import '@fortawesome/fontawesome-free/css/all'
import 'bootstrap/dist/js/bootstrap'
import 'ekko-lightbox/dist/ekko-lightbox.js'
import 'ekko-lightbox/dist/ekko-lightbox.min.js'
require("packs/photos")
require("packs/maps")
require("packs/bootstrap")
require("packs/owl.carousel")
require("packs/owl.carousel.min")

Rails.start()
Turbolinks.start()
ActiveStorage.start()

