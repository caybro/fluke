#include "sound.h"

#include <QString>
#include <QDebug>

Sound::Sound(QObject *parent)
    : QObject(parent)
{
    QMetaObject::invokeMethod(this, "init");
}

Sound::~Sound()
{
    delete m_pulse;
    m_pulse = nullptr;
}

int Sound::volume() const
{
    return get_selected_device().volume_percent;
}

void Sound::setVolume(int vol)
{
    if (vol != volume()) {
        pa_volume_t new_value = qRound( (double)vol * (double)PA_VOLUME_NORM / 100.0);
        Device dev = get_selected_device();
        m_pulse->set_volume(dev, new_value);
        Q_EMIT volumeChanged(new_value);
    }
}

bool Sound::isMuted() const
{
    return get_selected_device().mute;
}

void Sound::setMuted(bool muted)
{
    if (muted != isMuted()) {
        Device dev = get_selected_device();
        m_pulse->set_mute(dev, muted);
        Q_EMIT isMutedChanged(muted);
    }
}

bool Sound::available() const
{
    return m_available;
}

void Sound::init()
{
    try {
        m_pulse = new Pulseaudio("fluke");
    }
    catch (const char* message) {
        qWarning() << qUtf8Printable(message);
        return;
    }
    catch (const std::exception& e) {
        qWarning() << e.what();
        return;
    }
    m_available = true;
    Q_EMIT availableChanged(true);
}

Device Sound::get_selected_device(bool source) const
{
    if (source) {
        return m_pulse->get_default_source(); // input
    }

    return m_pulse->get_default_sink(); // output
}
