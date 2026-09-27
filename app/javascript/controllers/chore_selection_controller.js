import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chore-selection"
export default class extends Controller {
  static targets = ["checkbox", "added", "submit"]

  connect() {
    this.update()
  }

  update() {
    const checked = this.checkboxTargets.filter((checkbox) => checkbox.checked)
    const minutes = checked.reduce((sum, checkbox) => sum + Number(checkbox.dataset.minutes), 0)

    this.addedTarget.textContent = `+${minutes}分`
    this.submitTarget.disabled = checked.length === 0
  }
}
