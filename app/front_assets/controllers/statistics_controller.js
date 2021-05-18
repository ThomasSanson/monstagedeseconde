import { Controller } from 'stimulus';
import { changeURLFromEvent} from '../utils/urls';

export default class extends Controller {
  filterByDepartment(event) {
    changeURLFromEvent(event, 'department');
  }

  filterByAcademy(event) {
    changeURLFromEvent(event, 'academy');
  }

  filterByPublicy(event) {
    changeURLFromEvent(event, 'is_public');
  }

  filterBySchoolTrack(event) {
    changeURLFromEvent(event, 'school_track');
  }

  filterBySchoolYear(event) {
    changeURLFromEvent(event, 'school_year');
  }

  filterBySubscribedSchool(event) {
    changeURLFromEvent(event, 'subscribed_school');
  }

  filterByDetailedTypology(event) {
    changeURLFromEvent(event, 'detailed_typology');
  }

  useDimension(event) {
    changeURLFromEvent(event, 'dimension');
  }
}

