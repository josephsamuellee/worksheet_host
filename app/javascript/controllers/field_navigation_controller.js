import { Controller } from "@hotwired/stimulus"

// Enter in a text field moves focus to the next interactive field.
export default class extends Controller {
  onKeydown(event) {
    if (event.key !== "Enter") return

    event.preventDefault()

    const fields = Array.from(
      this.element.querySelectorAll("input.worksheet-input, input[type='checkbox']")
    )
    const index = fields.indexOf(event.target)
    if (index < 0) return

    const next = fields[index + 1]
    if (next) next.focus()
  }
}
