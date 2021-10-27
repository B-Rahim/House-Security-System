# **I- Introduction**

In this project we design a home automation system called *Safe* to controle a house made up of device operating at low consumption (by exploiting the ARM7 EJ-S architecture) as well as the development of a multiplatform mobile application using Flutter that communicates with the embedded device through the GSM network to control the actuators and to view the data collected by the sensors.

# **II- Description of the device**
The device utilizes the LinkIt ONE board powered by a battery, a motion detector module and a passive speaker ( LM384 module) placed in a box. The device will monitor the space delimited by an opening angle of 120 ° and a radius of 7m. If the system detects movement, it triggers a siren and sends an SMS to the owner containing the message “INTRUSION DETECTED.” The owner has a mobile application that will allow him to pair his phone with the device via Bluetooth. The app also allows the owner to register multiple devices Safe and see the history of messages received from and sent to each of those devices

*The motion is detected when an object enters the image and emits a different thermal signature.*

![Thermal](/README_images/Thermal_Image.png "Thermal image")


# **III- Adopted solutions**

### **1- Communication via BLE**
**Bluetooth Low Energy** technology operates in the ISM 2.4 GHz free band (Industrial, Scientific and Medical use). This technology is based on a frequency hopping radio to combat the 'interference and frequency fading and provides many carriers FHSS (Frequency Hopping Spread Spectrum) Simple modulation (Gaussian Freq uency Shift Keying - GFSK) is chosen to reduce the complexity of the radio.

With BLE technology, one device (the master) will establish a link with another device (the slave) using the GATT protocol. This protocol specifies how data is stored and exchanged. The slave is a GATT server and the master is a GATT client. In other words, the server serves data to a client.
 GATT transactions in Bluetooth 4.0 and later are based on high-level nested objects called profiles, services, and characteristics, as shown below:

![GATT](/README_images/GATT.png "GATT protocol")

 
**Profiles:** Profiles are high-level definitions that define how services can be used to activate an app or use case. 

**Services:** Services are sets of characteristics and relationships with other services that encapsulate the behavior of part of a device. Services are identified by a unique identifier called UUID. These can be user-defined IDs 16 (official GATT specification) or 128-bit.

**Characteristics:** Each service has a number of characteristics. Characteristics store values ​​and authorizations for the service. Each characteristic has at least two attributes, the main attribute and a value attribute that contains the value. The primary attribute identifies the value attribute using its UUID.

Types of data transfer: There are four different ways to initiate data transfers: read, write, notify, and indicate.

In the case of our project, the GATT server is the LinkIt One card and the GATT client is the mobile phone. In our implementation, the card offers a “PAIR” service containing two characteristics. The first is of type Read whose value is the cell number of LinkIt ONE. The phone will read this number to register the device in its database. The second is of type write where the mobile phone will write its own number so that it is saved in the device.

![profile](/README_images/profile.png "profile")


An UUID that starts with 8 characters “A” is given to the new service to distinguish it, the UUIDs of the Read and Write characteristics that start with “0000” and “1111” respectively. 

### **2-SQLite database**
To store the data of the mobile application (names, addresses, telephone numbers, sms ... etc) a relational database is created with SQLite. Using SQL statements, one can query, update, reorganize data, as well as create and modify the structure of the database system and control access to this data. The particularity of SQLite compared to other DBSMs is that it is not a client-server database engine but rather integrated into the program of the mobile application. It is designed to take up less memory space.

In addition, all transactions in SQLite are fully ACID compliant. This means that all requests and modifications are atomic, consistent, isolated, and durable.

In other words, all changes within a transaction take place completely or not at all, even when an unexpected situation, such as an application failure, power failure, or system failure. 

The database of the mobile application contains the tables: **Messages** and **Houses**.  The two tables have a one-to-many relationship (a House can have multiple Messages) in which the foreign-key of the Messages table is idHouse. The following figure shows the conceptual model of the implemented relational database, where PK stands for *primary key* and FK stands for *foreign key*.

![database](/README_images/database.png "Database")

            Conceptual model of the implemented database
 
### **3- GSM mobile networks and the SMS service**
The transmission of SMS between a mobile and a recipient (other mobile, 3G key with the appropriate software, fixed equipment, etc.) and vice versa can be carried out through different protocols such as SS7 as part of the GSM standard protocol, or even TCP / IP with the same standard. The messages are sent with the additional operation forward_short_message, the payload length of which is limited by the constraints of the signaling protocol, namely 140 bytes at most. In practice, this translates either to 160 characters in 7-bit encoding, or by 140 characters in 8-bit encoding, or even by 70 characters in 16-bit encoding. 


 
 
In our on-board home automation system, the LinkIt ONE card is an SME, it is equipped with a GSM antenna operating in 850/900/1800/1900MHz frequency bands with a transfer rate that varies between 9.6 and 14.4kbps depending on the band of the operator's network used. The card can therefore transmit an SMS in real time during an intrusion. 

### **4-Mobile application**

As part of this project, we opted for Dart with the Flutter framework proposed by Google which allows the development of multiplatform applications i.e. which can be installed on Android and iOS. 

The mobile application follows the MVC design pattern as in the Model part we define the models of the Houses and Messages data (described in section SQLite Database), in the View part we define the different pages of the application (also called screens), and in the controller part we define the functionalities of the application such as the bluetooth connection, the transmission / reception of SMS, the addition of a new house… etc.


The source code of the application is therefore organised as follows:

![source](/README_images/source.png "source code organisation")

#### a. Main

In the main file main.dart we define the named routes that the browser of the application can take as well as properties of the user interface theme (such as the color , the format of the text, the style of the buttons ... etc).
#### b.The Pages directory

It contains the various files defining the pages constituting our application as well as the associated widgets. Depending on the need we use two different types of widgets, Stateless widgets which are static (having a constant form in their life) and the other called Stateful which are reconstructed dynamically as they are used.

![screens](/README_images/screens.png "App's different screens")


#### c.The utils
This directory contains 3 utility files. In db_helper.dart we define the class of our database following the *signleton* design pattern (restriction of the instantiation of the class to a single object) along with APIs to perform CRUD operations (create, read, update and delete ). 

The files house_widget.dart and ble_widget.dart contain two widgets that belong to the Home and Scan-BLE pages respectively. The implementation of these two widgets was quite long so that we preferred to put them in a separate file to make the code easier to read.

**User Permission**: Before being able to use the application the user must grant certain permissions in order to let it access some of the features on the phone. The following permissions are added into the AndroidManifest.xml file:


```
<android uses-permission: name = "android.permission.SEND_SMS" /> 
<android uses-permission: name = "android.permission.RECEIVE_SMS" />
<android uses-permission: name = "android.permission.BLUETOOTH" />
<android uses-permission: name = "android.permission.BLUETOOTH_ADMIN" />
<android uses-permission: name = "android.permission.ACCESS_COARSE_LOCATION" />
```
### **5-Linkit One development board**
The LinkIt ONE platform is intended for prototyping and evaluation. This board has been specially developed for applications in the Internet of Things (IoT) and connected clothing (Wearable), the board is compatible with the Arduino development environment, and embeds the GSM, GPRS, Wifi, Bluetooth functions, GPS and audio. It is equipped with the MT2502A SoC processor. In this project, we used the GSM and BLE functionalities.

### **6-Embedded software**
The embedded application is implemented as a finite state machine. This choice is widely adopted in real-time systems which depend on inputs and the previous state. Another advantage of this approach is that it makes it easier to add new tasks to the system.
 The four composing states are IDLE, PAIR, DETECT, ALARM. The transition conditions are motion detection (MO), push button pressed (PB), Time Out (TO1 and TO2) and registered device (RG).

**IDLE**: In this state, the processor checks if an SMS is received to read it. It also reads the value of the input attached to the push button. If it is pressed then the PB condition is verified and the next state would be PAIR.

**PAIR**: In this state the LinkIt board becomes a BLE server and listens for a request from a client for 30 seconds. If a client (the smartphone) connects to the device and exchanges the phone number successfully, the RG condition will be verified, the FSM returns to the IDLE state. If the 30 seconds are elapsed, it returns to the IDLE state as well.

**DETECT**: This state corresponds to the detection of a movement. The motion detector is attached to an interrupt line, when it detects a movement it goes from the IDLE state to the DETECT state where a message is sent to the previously registered number, and the interrupt line is temporarily masked.

**ALARM:** In this state a siren is activated for 10 seconds. After these 10 seconds the interrupt line is unmasked then the FSM goes to IDLE state.

![FSM](/README_images/FSM.png "Finite State Machine")

### **7-Choice of hardware and software**

| Hardware/Software    | Choice                   |
|----------------------|--------------------------|
| Development Board    | LinkIt ONE               |
| Motion Sensor        | HC-SR501                 |
| Speaker Module       | LM386                    |
| Passive Speaker      | 8Ohm - 0.5W              |
| Battery              | 3.7V - 1050mAh           |
| IDE                  | Android Studio + Arduino |
| Mobile App Framework | Flutter                  |





# **IV- Conclusion**
Despite the fact that the functionalities offered by this device are quite simple for the time being, the source code of  this project would be a perfect starting point for more complex applications.
