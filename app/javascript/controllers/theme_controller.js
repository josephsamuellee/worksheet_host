import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "worksheet-host-theme"

function currentTheme() {
  return document.documentElement.dataset.theme === "light" ? "light" : "dark"
}

function applyTheme(theme) {
  const next = theme === "light" ? "light" : "dark"
  document.documentElement.dataset.theme = next
  try {
    localStorage.setItem(STORAGE_KEY, next)
  } catch (_) {
    // localStorage may be unavailable in private mode; theme still applies for this page.
  }
}

export default class extends Controller {
  static targets = ["button"]

  connect() {
    this.syncLabel()
  }

  toggle() {
    applyTheme(currentTheme() === "dark" ? "light" : "dark")
    this.syncLabel()
  }

  syncLabel() {
    if (!this.hasButtonTarget) return
    this.buttonTarget.textContent =
      currentTheme() === "dark" ? "Light mode" : "Dark mode"
  }
}
