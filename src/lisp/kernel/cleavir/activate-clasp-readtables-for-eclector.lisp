(in-package :eclector.readtable)

(defmethod eclector.readtable:syntax-type  ((readtable cl:readtable) char)
  (core:syntax-type readtable char))

(defmethod eclector.readtable:get-macro-character ((readtable cl:readtable) char)
  (cl:get-macro-character char readtable))

(defmethod eclector.readtable:set-macro-character
    ((readtable cl:readtable) char function &optional non-terminating-p)
  (cl:set-macro-character char function non-terminating-p readtable))
 
(defmethod eclector.readtable:get-dispatch-macro-character ((readtable cl:readtable) disp sub)
  (cl:get-dispatch-macro-character disp sub readtable))
 
(defmethod eclector.readtable:set-dispatch-macro-character
    ((readtable cl:readtable) disp sub function)
  (cl:set-dispatch-macro-character disp sub function readtable))
 
(defmethod eclector.readtable:copy-readtable ((readtable cl:readtable))
  (cl:copy-readtable readtable))

(defmethod eclector.readtable:copy-readtable-into ((from cl:readtable) (to cl:readtable))
  (cl:copy-readtable from to))
 
(defmethod eclector.readtable:make-dispatch-macro-character
    ((readtable cl:readtable) char &optional non-terminating-p)
  (cl:make-dispatch-macro-character char non-terminating-p readtable))

(defmethod eclector.readtable:readtable-case (readtable)
  (error 'type-error :datum readtable :EXPECTED-TYPE 'cl:readtable))

(defmethod eclector.readtable:readtable-case ((readtable cl:readtable))
  (cl:readtable-case readtable))
 
(defmethod (setf eclector.readtable:readtable-case) (mode (readtable cl:readtable))
  (setf (cl:readtable-case readtable) mode))

(defmethod (setf eclector.readtable:readtable-case) (mode readtable)
  (error 'type-error :datum readtable :EXPECTED-TYPE 'cl:readtable))
 
(defmethod eclector.readtable:readtablep ((object cl:readtable)) t)

(defvar core:*read-hook*)
(defvar core:*read-preserving-whitespace-hook*)


;;; to avoid that cl:*readtable* and eclector.readtable:*readtable* get out of sync
;;; to avoid eclector.parse-result::*stack* being unbound, when *client* is bound to a parse-result-client
;;; Not sure whether this a a fortunate design in eclector

(defun read-with-readtable-synced (&optional
                                      (input-stream *standard-input*)
                                      (eof-error-p t)
                                      (eof-value nil)
                                      (recursive-p nil))
  (let ((eclector.readtable:*readtable* cl:*readtable*)
        (ECLECTOR.READER:*CLIENT* nil))
    #+(or)(format t "stream ~a eof-p ~a eofv ~a recur ~a~%" input-stream eof-error-p eof-value recursive-p)
    (eclector.reader:read input-stream eof-error-p eof-value recursive-p)))

;;; to avoid th cl:*readtable* and eclector.readtable:*readtable* get out of sync
(defun read-preserving-whitespace-with-readtable-synced (&optional
                                                           (input-stream *standard-input*)
                                                           (eof-error-p t)
                                                           (eof-value nil)
                                                           (recursive-p nil))
  (let ((eclector.readtable:*readtable* cl:*readtable*)
        (ECLECTOR.READER:*CLIENT* nil))
    (eclector.reader:read-preserving-whitespace input-stream eof-error-p eof-value recursive-p)))

;;; need also sync in clasp-cleavir::cclasp-loop-read-and-compile-file-forms


(defun cl:read-from-string (string
                            &optional (eof-error-p t) eof-value
                            &key (start 0) (end (length string))
                              preserve-whitespace)
  (let ((ECLECTOR.READER:*CLIENT* nil))
    (ECLECTOR.READER:READ-FROM-STRING string eof-error-p eof-value
                                      :start start :end end :preserve-whitespace preserve-whitespace)))

(defun init-clasp-as-eclector-reader ()
  (setq eclector.readtable:*readtable* cl:*readtable*)
  (eclector.reader::set-standard-macro-characters cl:*readtable*)
  (eclector.reader::set-standard-dispatch-macro-characters cl:*readtable*)
  (cl:set-dispatch-macro-character #\# #\a 'core:sharp-a-reader cl:*readtable*)
  (cl:set-dispatch-macro-character #\# #\A 'core:sharp-a-reader cl:*readtable*)
  (cl:set-dispatch-macro-character #\# #\I #'core::read-cxx-object cl:*readtable*)
  (cl:set-dispatch-macro-character #\# #\! 'core::sharp-!-reader cl:*readtable*)
  ;;; Crosscompile sbcl fails w/o that
  (cl:set-dispatch-macro-character #\# #\s 'core:sharp-s-reader cl:*readtable*)
  (cl:set-dispatch-macro-character #\# #\S 'core:sharp-s-reader cl:*readtable*)

  ;;; also change read 
  (setq core:*read-hook* 'read-with-readtable-synced)
  (setq core:*read-preserving-whitespace-hook* 'read-preserving-whitespace-with-readtable-synced)
  ;;; read-from-string calls read or read-preserving-whitespace
  )

(eclector.readtable::init-clasp-as-eclector-reader)  


