import { Controller } from "@hotwired/stimulus"

// Debounced autosave for worksheet responses.
export default class extends Controller {
  static targets = ["status", "form"]
  static values = {
    url: String,
    debounce: { type: Number, default: 750 }
  }

  connect() {
    this.dirty = false
    this.pending = {}
    this.lastEditedFieldKey = null
    this.timer = null
    this.setStatus("")
  }

  disconnect() {
    if (this.timer) clearTimeout(this.timer)
  }

  onTextInput(event) {
    this.queueField(event.target, this.debounceValue)
  }

  onTextChange(event) {
    this.queueField(event.target, 0)
  }

  onCheckboxChange(event) {
    this.queueField(event.target, 50)
  }

  queueField(element, delay) {
    const key = element.dataset.fieldKey
    if (!key) return

    let value
    if (element.type === "checkbox") {
      value = element.checked
    } else {
      value = element.value
    }

    this.pending[key] = value
    this.lastEditedFieldKey = key
    this.dirty = true
    this.setStatus("Saving…")

    if (this.timer) clearTimeout(this.timer)
    this.timer = setTimeout(() => this.flush(), delay)
  }

  async flush() {
    if (!this.dirty) return

    const payload = {
      answers: { ...this.pending },
      last_edited_field_key: this.lastEditedFieldKey
    }
    this.pending = {}
    this.dirty = false

    const token = document.querySelector("meta[name='csrf-token']")?.content

    try {
      const response = await fetch(this.urlValue, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-CSRF-Token": token,
          "X-Requested-With": "XMLHttpRequest"
        },
        body: JSON.stringify(payload)
      })

      if (!response.ok) throw new Error(`HTTP ${response.status}`)

      const data = await response.json()
      if (!data.ok) throw new Error(data.error || "Save failed")

      this.setStatus("Saved")

      if (data.last_edited_field_key) {
        const jumpRoot = this.element
        jumpRoot.dataset.jumpToLastEditFieldKeyValue = data.last_edited_field_key
        const jumpButton = jumpRoot.querySelector("[data-jump-to-last-edit-target='button']")
        if (jumpButton) jumpButton.hidden = false
      }
    } catch (error) {
      this.dirty = true
      this.setStatus("Save failed")
      console.error("Autosave failed", error)
    }
  }

  setStatus(text) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = text
      this.statusTarget.dataset.state = text.toLowerCase().replace(/\s+/g, "-")
    }
  }
}
