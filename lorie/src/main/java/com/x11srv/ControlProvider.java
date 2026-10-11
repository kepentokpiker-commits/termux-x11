package com.x11srv;

import android.content.ContentProvider;
import android.content.ContentValues;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Binder;
import android.os.Bundle;
import android.os.Process;

/** Control channel for preferences. Provider calls are not dropped by Hiber when the app is in background. */
public class ControlProvider extends ContentProvider {
    @Override
    public boolean onCreate() {
        return true;
    }

    @Override
    public Bundle call(String method, String arg, Bundle extras) {
        int uid = Binder.getCallingUid();
        if (uid != 0 && uid != 2000 && uid != Process.myUid())
            throw new SecurityException("Not allowed.");
        if (getContext() == null || !"pref".equals(method))
            throw new IllegalArgumentException("Unknown method: " + method);

        final int[] code = {1};
        final String[] text = {""};
        IRemoteCmdImterface.Stub stub = new IRemoteCmdImterface.Stub() {
            @Override
            public void exit(int c, String output) {
                code[0] = c;
                text[0] = output;
            }
        };

        Intent intent = new Intent("com.x11srv.CHANGE_PREFERENCE");
        if (extras != null)
            intent.putExtras(extras);
        Bundle holder = new Bundle();
        holder.putBinder(null, stub);
        intent.putExtra(null, holder);

        new LoriePreferences.Receiver().onReceive(getContext(), intent);

        Bundle result = new Bundle();
        result.putInt("code", code[0]);
        result.putString("text", text[0]);
        return result;
    }

    @Override public Cursor query(Uri u, String[] p, String s, String[] a, String o) { return null; }
    @Override public String getType(Uri u) { return null; }
    @Override public Uri insert(Uri u, ContentValues v) { return null; }
    @Override public int delete(Uri u, String s, String[] a) { return 0; }
    @Override public int update(Uri u, ContentValues v, String s, String[] a) { return 0; }
}
