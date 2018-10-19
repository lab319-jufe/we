# -*- coding: utf-8 -*-
"""
Created on Fri Oct 19 14:46:03 2018

@author: haoyun
"""

'''ROC曲线:描述TPR和FPR之间的关系
   TPR(True Positive Rate)=TP/(TP+FN)=recall
   FPR(False Positive Rate)=FP/(TN+FP)'''
import numpy as np
import matplotlib.pyplot as plt
from sklearn import datasets
digits = datasets.load_digits()
X = digits.data
y = digits.target.copy()

y[digits.target==9] = 1
y[digits.target!=9] = 0

from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X, y, random_state=666)
from sklearn.linear_model import LogisticRegression
log_reg = LogisticRegression()
log_reg.fit(X_train, y_train)
decision_scores = log_reg.decision_function(X_test)

from MLself.metrics import FPR,TPR
fprs = []
tprs = []
thresholds = np.arange(np.min(decision_scores), np.max(decision_scores), 0.1)
for threshold in thresholds:
    y_predict = np.array(decision_scores >= threshold, dtype='int')
    fprs.append(FPR(y_test, y_predict))
    tprs.append(TPR(y_test, y_predict))

plt.plot(fprs, tprs)
plt.show()

#scikit-learn中的ROC
from sklearn.metrics import roc_curve
fprs, tprs, thresholds = roc_curve(y_test, decision_scores)
plt.plot(fprs, tprs)
plt.show()#ROC与x轴围成的面积越大，ROC表现越好，模型预测越好

from sklearn.metrics import roc_auc_score#求面积
roc_auc_score(y_test, decision_scores)