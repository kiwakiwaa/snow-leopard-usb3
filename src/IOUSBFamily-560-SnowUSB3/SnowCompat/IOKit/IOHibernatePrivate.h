#ifndef __IOKIT_IOHIBERNATEPRIVATE_H
#define __IOKIT_IOHIBERNATEPRIVATE_H

enum
{
    kIOHibernateStateInactive = 0,
    kIOHibernateStateHibernating = 1,
    kIOHibernateStateWakingFromHibernate = 2
};

#define kIOHibernateStateKey "IOHibernateState"

#endif
