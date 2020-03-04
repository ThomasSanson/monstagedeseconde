import { Controller } from 'stimulus';
import $ from 'jquery';
import { hideElement, showElement } from '../utils/dom';

const isValidDay = dayStr => {
  const minDay = 1;
  const maxDay = 31;
  const dayInt = parseInt(dayStr, 10);

  return dayInt >= minDay && dayInt <= maxDay;
};
const isValidMonth = monthStr => {
  const minMonth = 1;
  const maxMonth = 12;
  const monthInt = parseInt(monthStr, 10);

  return monthInt >= minMonth && monthInt <= maxMonth;
};
const isValidYear = yearStr => {
  const isTwoDigitsYear = yearStr.length == 2;
  if (isTwoDigitsYear) {
    return true
  } else {
    const minYear = 1950;
    const maxYear = new Date().getFullYear();
    const yearInt = parseInt(yearStr, 10);

    return yearInt >= minYear && yearInt <= maxYear;
  }
};

// see: https://ux.stackexchange.com/questions/1232/most-user-friendly-form-fields-for-entering-date-time
export default class extends Controller {
  static targets = ['input'];

  validate() {
    const $input = $(this.inputTarget);
    const { value } = this.inputTarget;
    const match = /(?<day>\d{1,2})(\/|-)?(?<month>\d{1,2})(\/|-)?(?<year>\d{2,4})/.exec(value);
    const { day, month, year } = (match || {}).groups || {};

    if (isValidYear(year) && isValidMonth(month) && isValidDay(day)) {
      $input.val(`${day}/${month}/${year.toString().padStart(4, "20")}`)
            .removeClass('is-invalid')
    } else {
      $input.addClass('is-invalid')
    }
  }
}
