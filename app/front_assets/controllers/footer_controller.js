import $ from 'jquery';
import { Controller } from 'stimulus';
import { hideElement } from '../utils/dom';

export default class extends Controller {
  static targets = ['placeholder', 'fixedContent'];

  saveAndQuit() {
    $('#internship_agreement_event').val('start_by_employer');
    $('#submit').click();
  }

  close() {
    hideElement($(this.fixedContentTarget));
    this.resize();
    localStorage.setItem('fixedFooterShown', true);
  }

  resize() {
    $(this.placeholderTarget).height($(this.fixedContentTarget).height());
  }

  connect() {
    setTimeout(this.resize.bind(this), 0);

    if (!localStorage.getItem('fixedFooterShown')) {
      this.fixedContentTarget.classList.remove('d-none');
    }
  }
}
