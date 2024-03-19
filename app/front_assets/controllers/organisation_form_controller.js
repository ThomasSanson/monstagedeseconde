import { Controller } from 'stimulus';
import $ from 'jquery';
import { showElement, hideElement } from '../utils/dom';

export default class extends Controller {
  static targets = [
    'groupBlock',
    'groupLabel',
    'groupNamePublic',
    'groupNamePrivate',
    'requiredField'
  ];

  validateForm(event) {
    const latitudeInput = document.getElementById('internship_offer_coordinates_latitude');
    if (!latitudeInput.validity.valid) {
      document.getElementById('js-internship_offer_autocomplete').focus();
    }
    return event;
  }

  handleClickIsPublic(event) {
    // const { value } = event.target;
    // showElement($(this.groupBlockTarget));
    // if (event.target.value === 'true') {
    //   $(this.groupLabelTarget).html(`
    //     Institution de tutelle
    //     <abbr title="(obligatoire)" aria-hidden="true">*</abbr>
    //   `);
    // } else {
    //   $(this.groupLabelTarget).text('Groupe (optionnel)');
    // }
    // this.toggleGroupNames(value === 'true');
  }

  toggleGroupNames(isPublic) {
    // if (isPublic) {
    //   $(this.selectGroupNameTarget)
    //     .find('option')
    //     .first()
    //     .text('-- Veuillez sélectionner une institution de tutelle --');
    //   $(this.groupNamePublicTargets).show();
    //   $(this.groupNamePrivateTargets).hide();
    // } else {
    //   $(this.selectGroupNameTarget)
    //     .find('option')
    //     .first()
    //     .text('-- Indépendant --');
    //   $(this.groupNamePublicTargets).hide();
    //   $(this.groupNamePrivateTargets).show();
    // }
  }

  checkForm() {
    const requiredFields = this.requiredFieldTargets;
    const submitButton = this.submitButtonTarget;

    requiredFields.forEach(field => {
      field.addEventListener('input', () => {
        for (const requiredField of requiredFields) {
          if (requiredField.value === '') {
            submitButton.disabled = true;
            return;
          }
        }
        submitButton.disabled = false;
      });
    });
  }

  connect() {
    // this.element.addEventListener('submit', this.validateForm, false);
    setTimeout( () => {
      // this.toggleGroupNames(false);
      this.checkForm();
    }, 100);
  }

  disconnect() {}
}
