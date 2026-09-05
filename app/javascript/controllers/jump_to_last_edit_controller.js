import { Controller } from "@hotwired/stimulus"

// Scrolls to and highlights the server-persisted last-edited field.
export default class extends Controller {
  static targets = ["button"]
  static values = {
    fieldKey: String
  }

  jump(event) {
    event.preventDefault()
    const key = this.fieldKeyValue
    if (!key) return

    const el = this.element.querySelector(`[data-field-key="${CSS.escape(key)}"]`)
    if (!el) return

    el.scrollIntoView({ behavior: "smooth", block: "center" })

    const highlightTarget = el.closest(".worksheet-checkbox") || el
    highlightTarget.classList.add("field-highlight")
    window.setTimeout(() => highlightTarget.classList.remove("field-highlight"), 1600)

    if (el.type === "text" || el.dataset.fieldType === "input") {
      el.focus({ preventScroll: true })
    }
  }
}
