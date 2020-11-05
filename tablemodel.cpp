#include "tablemodel.h"

int TableModel::rowCount(const QModelIndex &) const
{
    qint32 rows{0};
    QFile file("file.txt");

    if (!file.open( QIODevice::ReadOnly) )
        return rows;

    QTextStream stream(&file);
    stream.setCodec("Windows-1251");

    while (!stream.atEnd())
    {
        QString str = stream.readLine();
        QStringList list = str.split(QRegularExpression(";."));
        if(!columns)
            columns = list.size();
        rows++;
        for(auto i : list)
            vec.push_back(i.left(i.indexOf(";")));
    }
    return rows;
}

int TableModel::columnCount(const QModelIndex &) const
{
    return columns;
}

QVariant TableModel::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case Qt::DisplayRole:
        return QString(vec[index.column() + columns * index.row()]);
    default:
        break;
    }
    return QVariant();
}

QHash<int, QByteArray> TableModel::roleNames() const
{
    return { {Qt::DisplayRole, "display"} };
}

int TableModel::columns{2};
int TableModel::indx{0};
std::vector<QString> TableModel::vec{};


