import React, { Component } from "react";
import { connect } from "react-redux";
import PropTypes from "prop-types";
import styled from "styled-components";
import { FormattedMessage } from "react-intl";

import InputDisabled from "../InputDisabled";
import InputTimezone from "./InputTimezone";
import { changeTimezone } from "../../../../../shared/actions/UsersActions";
import NotificationsGroup from "./NotificationsGroup";

import {
  ASSIGNMENT_NOTIFICATION,
  RECENT_NOTIFICATION,
  SYSTEM_NOTIFICATION
} from "../constants";

import {
  MAIN_COLOR_BLUE,
  ICON_GREEN_COLOR,
  BORDER_LIGHT_COLOR
} from "../../../../../app/constants/colors";

const WrapperInputDisabled = styled.div`
  margin: 20px 0;
  padding-bottom: 15px;
  border-bottom: 1px solid ${BORDER_LIGHT_COLOR};

  .settings-warning {
    margin-top: -5px;
  }
`;

class SettingsPreferences extends Component {
  constructor(props) {
    super(props);

    this.state = {
      isTimeZoneEditable: false
    };
  }

  toggleIsEditable(fieldNameEnabled) {
    const editableState = this.state[fieldNameEnabled];
    this.setState({ [fieldNameEnabled]: !editableState });
  }

  render() {
    const isTimeZoneEditable = "isTimeZoneEditable";
    let timezoneField;

    if (this.state.isTimeZoneEditable) {
      timezoneField = (
        <InputTimezone
          labelValue="Time zone"
          inputValue={this.props.timezone}
          disableEdit={() => this.toggleIsEditable(isTimeZoneEditable)}
          saveData={timeZone => this.props.changeTimezone(timeZone)}
        />
      );
    } else {
      timezoneField = (
        <WrapperInputDisabled>
          <InputDisabled
            labelTitle="settings_page.time_zone"
            inputValue={this.props.timezone}
            inputType="text"
            enableEdit={() => this.toggleIsEditable(isTimeZoneEditable)}
          />
          <div className="settings-warning">
            <small>
              <FormattedMessage id="settings_page.time_zone_warning" />
            </small>
          </div>
        </WrapperInputDisabled>
      );
    }

    return (
      <div className="col-xs-12 col-sm-9">
        {timezoneField}

        <h3>Notifications</h3>
        <NotificationsGroup
          type={ASSIGNMENT_NOTIFICATION}
          title="settings_page.assignement"
          subtitle="settings_page.assignement_msg"
          imgUrl=""
          iconClasses="fa fa-newspaper-o"
          iconBackground={MAIN_COLOR_BLUE}
        />
        <NotificationsGroup
          type={RECENT_NOTIFICATION}
          title="settings_page.recent_changes"
          subtitle="settings_page.recent_changes_msg"
          imgUrl={this.props.avatarPath}
          iconClasses=""
          iconBackground=""
        />
        <NotificationsGroup
          type={SYSTEM_NOTIFICATION}
          title="settings_page.system_message"
          subtitle="settings_page.system_message_msg"
          imgUrl=""
          iconClasses="glyphicon glyphicon-tower"
          iconBackground={ICON_GREEN_COLOR}
        />
      </div>
    );
  }
}

SettingsPreferences.propTypes = {
  timezone: PropTypes.string.isRequired,
  changeTimezone: PropTypes.func.isRequired,
  avatarPath: PropTypes.string.isRequired
};

const mapStateToProps = state => state.current_user;
const mapDispatchToProps = dispatch => ({
  changeTimezone(timezone) {
    dispatch(changeTimezone(timezone));
  }
});

export default connect(mapStateToProps, mapDispatchToProps)(
  SettingsPreferences
);
