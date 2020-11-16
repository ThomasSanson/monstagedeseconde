import $ from 'jquery';
import { Controller } from 'stimulus';
import { showElement, hideElement } from '../utils/dom';
import { attach, detach, EVENT_LIST } from '../utils/events';
import { endpoints } from '../utils/api';
import { fetch } from 'whatwg-fetch';

// @schools [School, School, School]
// return {weekId: [school, ...]}
const mapNumberOfSchoolHavingWeek = (schools) => {
  const weeksSchoolsHash = {}

  $(schools).each((i, school) => {
    $(school.weeks).each((i,week)=>{
      weeksSchoolsHash[week.id] = (weeksSchoolsHash[week.id]||[]).concat([school])
    })
  });
  return weeksSchoolsHash
}
export default class extends Controller {
  static targets = ['checkboxesContainer', 'weekCheckboxes', 'hint', 'inputWeekLegend'];

  connect() {
    if (this.getForm() === null) {
      return;
    }

    this.onCoordinatesChangedRef = this.fetchSchoolsNearby.bind(this)
    this.onSubmitRef = this.handleSubmit.bind(this);
    this.onApiSchoolsNearbySuccess = this.showSchoolDensityPerWeek.bind(this);

    this.attachEventListeners()
  }

  disconnect() {
    this.detachEventListeners();
  }

  attachEventListeners() {
    attach(EVENT_LIST.COORDINATES_CHANGED, this.onCoordinatesChangedRef);
    $(this.getForm()).on('submit', this.onSubmitRef);
  }

  detachEventListeners() {
    detach(EVENT_LIST.COORDINATES_CHANGED, this.onCoordinatesChangedRef);
    $(this.getForm()).off('submit',this.onSubmitRef);
  }

  fetchSchoolsNearby(event) {
    fetch(endpoints.apiSchoolsNearby(event.detail), { method: 'POST' })
      .then((response) => response.json())
      .then(this.onApiSchoolsNearbySuccess);
  }

  showSchoolDensityPerWeek(schools) {
    const weeksSchoolsHash = mapNumberOfSchoolHavingWeek(schools);

    $(this.inputWeekLegendTargets).each( (i, el) => {
      const weekId = parseInt(el.getAttribute('data-week-id'), 10);
      const schoolCountOnWeek = (weeksSchoolsHash[weekId] || []).length

      el.innerText = `${schoolCountOnWeek.toString()} etbs`;
    })
  }

  // toggle all weeks options
  handleToggleWeeks(event) {
    if($('#all_year_long').is(":checked")){
      $(".custom-control-checkbox-list").addClass('d-none')
      $(".custom-control-checkbox-list").hide()
    } else {
      $(".custom-control-checkbox-list").hide()
      $(".custom-control-checkbox-list").removeClass('d-none')
      $(".custom-control-checkbox-list").slideDown()
    }

    $(this.weekCheckboxesTargets).each((i, el) => {
      $(el).prop('checked', $(event.target).prop('checked'));
    });
    if(event.target.checked){
       hideElement($(this.checkboxesContainerTarget));
    } else{
      showElement($(this.checkboxesContainerTarget));
    }
  }

  // on week checked
  handleCheckboxesChanges() {
    if (!this.hasAtLeastOneCheckbox()) {
      this.onAtLeastOneWeekSelected();
    } else {
      this.onNoWeekSelected();
    }
  }

  handleSubmit(event) {
    if (this.data.get('skip')) {
      return event;
    }
    if (!this.hasAtLeastOneCheckbox()) {
      this.onAtLeastOneWeekSelected();
    } else {
      this.onNoWeekSelected();
      event.preventDefault();
      return false;
    }
    return event;
  }

  // getters
  getFirstInput() {
    const inputs = this.weekCheckboxesTargets;
    return inputs[0];
  }

  getForm() {
    if (!this.getFirstInput() || !this.getFirstInput().form) {
      return null;
    }
    return this.getFirstInput().form;
  }

  hasAtLeastOneCheckbox() {
    const selectedCheckbox = $(this.weekCheckboxesTargets).filter(':checked');
    return selectedCheckbox.length === 0;
  }

  // ui helpers
  onNoWeekSelected() {
    const $hint = $(this.hintTarget);
    const $checkboxesContainer = $(this.checkboxesContainerTarget);

    showElement($hint);
    $checkboxesContainer.addClass('is-invalid');
  }

  onAtLeastOneWeekSelected() {
    const $hint = $(this.hintTarget);
    const $checkboxesContainer = $(this.checkboxesContainerTarget);

    hideElement($hint);
    $checkboxesContainer.removeClass('is-invalid');
  }
}
