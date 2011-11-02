;; -*- mode:Emacs-lisp -*-
;; Time-stamp: <2004-02-28 16:43:29 Yu Li>

;; make emacs be able to tell me when sunrise and sunset
(setq calendar-latitude +39.54)
(setq calendar-longitude +116.28)
(setq calendar-location-name "����")

;; make the infomation more readable to me
(setq chinese-calendar-celestial-stem
      ["��" "��" "��" "��" "��" "��" "��" "��" "��" "��"])
(setq chinese-calendar-terrestrial-branch
      ["��" "��" "��" "î" "��" "��" "��" "δ" "��" "��" "��" "��"])

(setq calendar-remove-frame-by-deleting t)
(setq calendar-week-start-day 1)
(setq mark-diary-entries-in-calendar t)
(setq appt-issue-message nil)
(setq mark-holidays-in-calendar nil)
(setq view-calendar-holidays-initially nil)

(setq mark-diary-entries-in-calendar t)
(setq appt-issue-message nil)
(setq mark-holidays-in-calendar t)
(setq view-calendar-holidays-initially nil)

;; I do not care these holidays
(setq christian-holidays nil)
(setq hebrew-holidays nil)
(setq islamic-holidays nil)
(setq solar-holidays nil)
(setq general-holidays '((holiday-fixed 1 1 "Ԫ��")
                         (holiday-fixed 2 14 "���˽�")
                         (holiday-fixed 3 14 "��ɫ���˽�")
                         (holiday-fixed 4 1 "���˽�")
                         (holiday-fixed 5 1 "�Ͷ���")
                         (holiday-float 5 0 2 "ĸ�׽�")
                         (holiday-fixed 6 1 "��ͯ��")
                         (holiday-float 6 0 3 "���׽�")
                         (holiday-fixed 7 1 "������")
                         (holiday-fixed 8 1 "������")
                         (holiday-fixed 9 10 "��ʦ��")
                         (holiday-fixed 10 1 "�����")
                         (holiday-fixed 12 25 "ʥ����")
                        ))