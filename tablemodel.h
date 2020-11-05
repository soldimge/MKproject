#pragma once

#include <QAbstractTableModel>
#include <QFile>
#include <vector>
#include <QRegularExpression>
#include <QTextStream>

class TableModel : public QAbstractTableModel
{
    Q_OBJECT

public:
    int rowCount(const QModelIndex & = QModelIndex()) const override;
    int columnCount(const QModelIndex & = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

private:
    static int columns;
    static int indx;
    static std::vector<QString> vec;
};
