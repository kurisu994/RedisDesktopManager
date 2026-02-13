#pragma once
#include <asyncfuture.h>
#include <QObject>
#include <QRegularExpression>
#include <QSharedPointer>
#include "abstractoperation.h"

namespace BulkOperations {

class CopyOperation : public AbstractOperation {
  Q_OBJECT
 public:
  CopyOperation(QSharedPointer<RedisClient::Connection> connection, int dbIndex,
                OperationCallback callback,
                QRegularExpression keyPattern = wildcardToRegex("*"));

  QString getTypeName() const override { return QString("copy_keys"); }

  bool multiConnectionOperation() const override { return true; }

  bool isMetadataValid() const override {
    return m_metadata.contains("ttl") && m_metadata.contains("replace");
  }

 protected:
  void performOperation(
      QSharedPointer<RedisClient::Connection> targetConnection,
      int targetDbIndex) override;

 private:
   QList<QList<QByteArray>> m_restoreBuffer;
   int m_dumpedKeys;

};
}  // namespace BulkOperations
