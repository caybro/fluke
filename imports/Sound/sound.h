#pragma once

#include <QObject>

#include "device.hh"
#include "pulseaudio.hh"

class Sound: public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool available READ available NOTIFY availableChanged)
    Q_PROPERTY(int volume READ volume WRITE setVolume NOTIFY volumeChanged)
    Q_PROPERTY(bool muted READ isMuted WRITE setMuted NOTIFY isMutedChanged)

public:
    Sound(QObject *parent = nullptr);
    virtual ~Sound();

    int volume() const;
    void setVolume(int vol);

    bool isMuted() const;
    void setMuted(bool muted);

    bool available() const;

private Q_SLOTS:
    void init();

Q_SIGNALS:
    void volumeChanged(int volume);
    void isMutedChanged(bool muted);
    void availableChanged(bool available);

private:
    Pulseaudio *m_pulse{nullptr};
    Device get_selected_device(bool source = false) const;
    bool m_available{false};
};
