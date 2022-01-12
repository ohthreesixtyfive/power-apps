Here in GitHub
- Download [custom-notification-bar-component-v1.msapp](https://github.com/ohthreesixtyfive/power-apps/blob/main/samples/custom-notification-bar-component/custom-notification-bar-component-v1.msapp).

Importing the Component
- In Power Apps, Open your respective ` Canvas App `.
- Select the ` Tree View ` from the left sidebar if its not already expanded.
- Select the ` Components ` tab in the Tree View.
- Click on the ` Ellipsis ('...') ` icon to the right of '+ New component'.
- Select ` Import components `.
- Select ` Upload file `, navigate to and Open the downloaded MSAPP file.
- ` cmpNotificationsV1 ` will be added to your Components Tree View.
- Select the ` Screens ` tab to exit the Component Tree View.

Using the Component
- In Power Apps, Open your respective ` Canvas App `.
- Select  ` Insert ('+') ` from the left sidebar if its not already selected.
- Expand the ` Custom ` section if not already expanded.
- Select ` cmpNotificationsV1 ` to add it to your canvas.

Component Custom Properties
<table>
<tr>
<td><strong>Property Name</strong></td>
<td><strong>Description</strong></td>
<td><strong>Type</strong></td>
<td><strong>Default</strong></td>
<td><strong>Required</strong></td>
</tr>
<tr>
<td> Notifications Collection </td>
<td> An input collection/table with the notifications to be displayed.<br />
  See <i>Notifications Collection Schema</i> section below for record schema. </td>
<td> Table </td>
<td> {Notification Record} </td>
<td> Yes </td>
</tr>
<tr>
<td> Show Action Button </td>
<td> Toggle to determine whether an Action button is displayed within the notification. </td>
<td> Boolean </td>
<td> true </td>
<td> Yes </td>
</tr>
<tr>
<td> Action Button Text </td>
<td> The Text to display within the Action button. </td>
<td> Text </td>
<td> "Action" </td>
<td> No </td>
</tr>
<tr>
<td> Action Button Formula </td>
<td> The formula that the Action button will execute when clicked within the notification.<br/>
     eg: Set(undoAction, true); </td>
<td> {Power Fx Formula} </td>
<td> false </td>
<td> No </td>
</tr>
</table>

Notifications Collection Schema
<table>
<tr>
<td><strong>Property</strong></td>
<td><strong>Type</strong></td>
<td><strong>Description</strong></td>
<td><strong>Required</strong></td>
</tr>
<tr>
<td> GUID </td>
<td> GUID </td>
<td> A unique identifier for this notification.<br />
     In most cases, this value of any notification record should be set using the GUID() function. </td>
<td> Yes </td>
</tr>
<tr>
<td> Text </td>
<td> Text </td>
<td> The text displayed in the notification. </td>
<td> Yes </td>
</tr>
<tr>
<td> Type </td>
<td> Text </td>
<td> The type of notification being displayed.<br />
     Default values available are "Success", "Error", "Warning", and "Information" </td>
<td> Yes </td>
</tr>
<tr>
<td> Timeout </td>
<td> Number </td>
  <td> The duration (in <i>milliseconds</i>) that the notification should persist before automatically being dismissed.<br />
  Durations of <i>0 (Zero)</i> will persist indefinitely until manually dismissed by the user. </td>
<td> Yes </td>
</tr>
</table>
