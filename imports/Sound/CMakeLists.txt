qt_add_qml_module(fluke_sound
    URI org.fluke.Sound
    SOURCES
        callbacks.cc
        callbacks.hh
        device.cc
        device.hh
        pulseaudio.cc
        pulseaudio.hh
        sound.cpp
        sound.h
)

target_link_libraries(fluke_sound
    PRIVATE
        PkgConfig::PulseAudio
)
