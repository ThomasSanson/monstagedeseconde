import { library, dom, config } from '@fortawesome/fontawesome-svg-core';
import {
  faAngleLeft,
  faArrowCircleLeft,
  faArrowCircleRight,
  faArrowCircleUp,
  faArrowRight,
  faArrowLeft,
  faBan,
  faBirthdayCake,
  faBus,
  faBuilding,
  faCalendarAlt,
  faCaretDown,
  faCaretRight,
  faCheck,
  faCheckCircle,
  faChevronCircleRight,
  faChevronDown,
  faChevronLeft,
  faChevronRight,
  faCircle as faCircleSolid,
  faComments,
  faDownload,
  faDesktop,
  faExchangeAlt,
  faExclamationTriangle,
  faExternalLinkAlt,
  faEye,
  faEyeSlash,
  faFileAlt,
  faFilePdf,
  faHistory,
  faHourglassStart,
  faInfoCircle,
  faInfo,
  faCopy,
  faLayerGroup,
  faMapMarker,
  faMapMarkerAlt,
  faMobileAlt,
  faMousePointer,
  faPen,
  faPrint,
  faPhone,
  faPlus,
  faSms,
  faSortDown,
  faSortUp,
  faSpinner,
  faSquare as faSquareSolid,
  faQuestionCircle,
  faRocket,
  faSchool,
  faSearch,
  faSignature,
  faSmile,
  faSuitcase,
  faTimes,
  faTrain,
  faTrash,
  faUniversalAccess,
  faUniversity,
  faUser,
  faUsers,
  faUserTie,
  faWalking
} from '@fortawesome/free-solid-svg-icons';

import {
  faCircle as faCircleRegular,
  faEnvelope,
  faFlag,
  faHandshake,
  faSquare as faSquareRegular,
} from '@fortawesome/free-regular-svg-icons';

// avoid SVG flickering
// see: https://github.com/FortAwesome/Font-Awesome/issues/11924
config.mutateApproach = 'sync';
library.add(
  faAngleLeft,
  faArrowCircleLeft,
  faArrowCircleRight,
  faArrowCircleUp,
  faArrowLeft,
  faArrowRight,
  faBan,
  faBirthdayCake,
  faBus,
  faBuilding,
  faCalendarAlt,
  faCaretDown,
  faCaretRight,
  faCheck,
  faCheckCircle,
  faChevronCircleRight,
  faChevronDown,
  faChevronLeft,
  faChevronRight,
  faCircleRegular,
  faCircleSolid,
  faComments,
  faDownload,
  faDesktop,
  faEnvelope,
  faExchangeAlt,
  faExclamationTriangle,
  faExternalLinkAlt,
  faEye,
  faEyeSlash,
  faFlag,
  faFileAlt,
  faFilePdf,
  faHandshake,
  faHistory,
  faHourglassStart,
  faInfoCircle,
  faInfo,
  faCopy,
  faLayerGroup,
  faMapMarker,
  faMapMarkerAlt,
  faMousePointer,
  faMobileAlt,
  faPen,
  faPhone,
  faPlus,
  faPrint,
  faSms,
  faSortDown,
  faSortUp,
  faSpinner,
  faSquareRegular,
  faSquareSolid,
  faQuestionCircle,
  faRocket,
  faSchool,
  faSearch,
  faSignature,
  faSmile,
  faSuitcase,
  faTimes,
  faTrain,
  faTrash,
  faUniversalAccess,
  faUniversity,
  faUser,
  faUsers,
  faUserTie,
  faWalking
);

// makes it works with Turbolink on document mutation
dom.watch({ observeMutationsRoot: document });
