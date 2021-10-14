import $ from 'jquery';
import { Controller } from 'stimulus';

export default class extends Controller {

  completeByEmployer() {
    $('#internship_agreement_event').val('complete');
  }

  validate() {
    $('#internship_agreement_event').val('validate');
    $('#submit').click();
  }

  connect() { 
  }
}
