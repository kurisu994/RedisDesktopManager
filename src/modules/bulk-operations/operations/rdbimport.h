#pragma once
#include <asyncfuture.h>
#include <QObject>
#include <QRegularExpression>
#include <QSharedPointer>
#include "abstractoperation.h"

class QPython;

namespace BulkOperations {

class RDBImportOperation : public AbstractOperation {
  Q_OBJECT
 public:
  RDBImportOperation(QSharedPointer<RedisClient::Connection> connection,
                     int dbIndex, OperationCallback callback,
                     QSharedPointer<QPython> p,
                     QRegularExpression keyPattern = wildcardToRegex("*"));

  QString getTypeName() const override { return QString("rdb_import"); }

  bool multiConnectionOperation() const override { return false; }

  void getAffectedKeys(
      std::function<void(QVariant, QString)> callback) override;

  bool isMetadataValid() const override;

 protected:
  void performOperation(
      QSharedPointer<RedisClient::Connection> targetConnection,
      int targetDbIndex) override;

 private:
  QSharedPointer<QPython> m_python;
};
}  // namespace BulkOperations
