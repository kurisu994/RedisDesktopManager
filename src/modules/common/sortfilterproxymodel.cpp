#include "sortfilterproxymodel.h"

#include "sortfilterproxymodel.h"
#include <QtDebug>
#include <QtQml>

SortFilterProxyModel::SortFilterProxyModel(QObject *parent) : QSortFilterProxyModel(parent), m_complete(false)
{
}

QObject *SortFilterProxyModel::source() const
{
    return sourceModel();
}

void SortFilterProxyModel::setSource(QObject *source)
{    
    auto m = qobject_cast<QAbstractItemModel *>(source);

    if (!m)
        return;

    setSourceModel(m);
}

QByteArray SortFilterProxyModel::sortRole() const
{
    return m_sortRole;
}

void SortFilterProxyModel::setSortRole(const QByteArray &role)
{
    if (m_sortRole != role) {
        m_sortRole = role;
        if (m_complete)
            QSortFilterProxyModel::setSortRole(roleKey(role));
    }
}

void SortFilterProxyModel::setSortOrder(Qt::SortOrder order)
{
    QSortFilterProxyModel::sort(0, order);
}

QByteArray SortFilterProxyModel::filterRole() const
{
    return m_filterRole;
}

void SortFilterProxyModel::setFilterRole(const QByteArray &role)
{
    if (m_filterRole != role) {
        m_filterRole = role;
        if (m_complete)
            QSortFilterProxyModel::setFilterRole(roleKey(role));
    }
}

QString SortFilterProxyModel::filterString() const
{
    return filterRegularExpression().pattern();
}

void SortFilterProxyModel::setFilterString(const QString &filter)
{
    setFilterRegularExpression(QRegularExpression(filter, static_cast<QRegularExpression::PatternOptions>(
        filterSyntax() == Wildcard ? QRegularExpression::NoPatternOption : QRegularExpression::NoPatternOption)));
    emit filterStringChanged();
}

SortFilterProxyModel::FilterSyntax SortFilterProxyModel::filterSyntax() const
{
    return m_filterSyntax;
}

void SortFilterProxyModel::setFilterSyntax(SortFilterProxyModel::FilterSyntax syntax)
{
    m_filterSyntax = syntax;
    setFilterString(filterString());
}

void SortFilterProxyModel::classBegin()
{
}

void SortFilterProxyModel::componentComplete()
{
    m_complete = true;
    if (!m_sortRole.isEmpty())
        QSortFilterProxyModel::setSortRole(roleKey(m_sortRole));
    if (!m_filterRole.isEmpty())
        QSortFilterProxyModel::setFilterRole(roleKey(m_filterRole));
}

int SortFilterProxyModel::getOriginalRowIndex(int i)
{
    QModelIndex proxyIndex = index(i, 0);
    return mapToSource(proxyIndex).row();
}

int SortFilterProxyModel::roleKey(const QByteArray &role) const
{
    QHash<int, QByteArray> roles = roleNames();
    QHashIterator<int, QByteArray> it(roles);
    while (it.hasNext()) {
        it.next();
        if (it.value() == role)
            return it.key();
    }
    return -1;
}
