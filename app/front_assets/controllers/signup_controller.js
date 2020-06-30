import $ from 'jquery';
import { Controller } from 'stimulus';
import ActionCable from 'actioncable';
import { toggleElement, showElement, hideElement } from '../utils/dom';

export default class extends Controller {
  static targets = ['handicapGroup',
                    'emailHint',
                    'emailInput',
                    'phoneInput',
                    'label',
                    'emailBloc',
                    'phoneBloc'];

  // on change email address, ensure user is shown academia address requirement when neeeded
  refreshEmailFieldLabel(event) {
    $(this.labelTarget).text(
      event.target.value == "school_manager" ?
      "Adresse électronique académique" :
      'Adresse électronique (e-mail)'
    )
  }

  // show/hide handicap input if checkbox is checked
  toggleHandicap() {
    toggleElement($(this.handicapGroupTarget));
  }

  // check email address formatting on email input blur (14yo student, not always good with email)
  onBlurEmailInput(event) {
    const email = event.target.value;
    if (email.length > 2) {
      this.validator.perform('validate', {
        email,
        uid: this.channelParams.uid,
      });
    }
  }

  connect() {
    const _that = this;
    const emailHintElement = this.emailHintTarget;
    const emailInputElement = this.emailInputTarget;
    const $hint = $(emailHintElement);
    const $input = $(emailInputElement);

    // setup wss to validate email (kind of history, tried to check email with smtp, not reliable)
    this.channelParams = { channel: 'MailValidationChannel', uid: Math.random().toString(36) };
    this.wssClient = ActionCable.createConsumer('/cable');
    this.validator = this.wssClient.subscriptions.create(this.channelParams, {
      received: data => {
        showElement($hint);

        switch (data.status) {
          case 'valid':
            $hint.attr('class', 'valid-feedback');
            $input.attr('class', 'form-control is-valid');
            emailHintElement.innerText = 'Votre email semble correct!';
            break;
          case 'invalid':
            $hint.attr('class', 'invalid-feedback');
            $input.attr('class', 'form-control is-invalid');

            emailHintElement.innerText =
              'Cette adresse éléctronique ne nous semble pas valide, veuillez vérifier';
            break;
          case 'hint':
            $hint.attr('class', 'invalid-feedback');
            $input.attr('class', 'form-control is-invalid');
            emailHintElement.innerText = `Peut être avez-vous fait une typo ? ${data.replacement}`;
            break;
          default:
            hideElement($hint);
        }
      },
    });

    setTimeout(function () {
      _that.checkChannel();
    }, 100);
  }

  disconnect() {
    try {
      this.wssClient.disconnect();
    } catch (e) {}
  }

  checkChannel() {
    switch (this.data.get('channel')) {
      case 'email':
        this.checkEmail();
        break;
      case 'phone':
        this.checkPhone();
        break;
      default:
        return;
    }
  }

  checkEmail() {
    this.displayField(this.phoneInputTarget, this.phoneBlocTarget, this.emailBlocTarget)
  }

  checkPhone() {
    this.displayField(this.emailInputTarget, this.emailBlocTarget, this.phoneBlocTarget)
  }

  displayField(fielfToClean, fieldToHide, fieldToDisplay) {
    $(fielfToClean).val('')
    $(fieldToHide).hide()
    $(fieldToHide).addClass('d-none')
    $(fieldToDisplay).hide()
    $(fieldToDisplay).removeClass('d-none')
    $(fieldToDisplay).slideDown()
  }

  focusPhone() {
    $('#phone-input').focus()
  }
}
