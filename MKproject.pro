QT += qml quick bluetooth gui

CONFIG += c++17

android: QT += androidextras

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

win32 {
    SOURCES = \
        appcore.cpp \
        main.cpp \
        wakecore.cpp

    HEADERS = \
        appcore.h \
        wakecore.h
}
android {
    SOURCES = \
        appcore.cpp \
        main.cpp \
        wakecore.cpp \
        keepawake.cpp

    HEADERS = \
        appcore.h \
        wakecore.h \
        keepawake.h
}

RESOURCES += qml.qrc

# StatusBar color changer library
include(StatusBar/statusbar.pri)

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

ANDROID_ABIS = armeabi-v7a

DISTFILES += \
    android/AndroidManifest.xml \
    android/build.gradle \
    android/gradle.properties \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew \
    android/gradlew.bat \
    android/res/drawable/icon.png \
    android/res/drawable/splash.xml \
    android/res/drawable/splash_image.png \
    android/res/values/libs.xml

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
android: include(C:/Users/by01.user/AppData/Local/Android/Sdk/android_openssl/openssl.pri)
