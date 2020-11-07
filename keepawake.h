#pragma once
#include <QAndroidJniObject>

class KeepAwake
{
public:
    KeepAwake();
    virtual ~KeepAwake();

private:
    QAndroidJniObject m_wakeLock;
};

