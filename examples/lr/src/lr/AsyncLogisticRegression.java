/* This file is part of VoltDB.
 * Copyright (C) 2008-2014 VoltDB Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

package lr;

//import java.util.concurrent.CyclicBarrier;

import org.voltdb.CLIConfig;
import org.voltdb.VoltTable;
import org.voltdb.client.Client;
import org.voltdb.client.ClientConfig;
import org.voltdb.client.ClientFactory;
import org.voltdb.client.ClientResponse;
import org.voltdb.client.ClientStats;
import org.voltdb.client.ClientStatsContext;
import org.voltdb.client.ClientStatusListenerExt;
import org.voltdb.client.NullCallback;
import org.voltdb.client.ProcedureCallback;

import lr.procedures.*;

public class AsyncLogisticRegression
{
    public static void main(String[] args) throws Exception {
        int dim = 3;
        double[] weights = new double[dim];
        double stepsize = 0.001;
        double lambda = 0.01;

        // init client
        Client client = null;
        ClientConfig config = null;
        try {
            client = ClientFactory.createClient();
            client.createConnection("localhost");
        } catch (java.io.IOException e) {
            e.printStackTrace();
            System.exit(-1);
        }
        client.createConnection("localhost");

        VoltTable keys = client.callProcedure("@GetPartitionKeys", "INTEGER").getResults()[0];
        int patitions = keys.getRowCount();

        try {
            for (int iter = 0; iter < 1000; iter++) {
                double[] grad = new double[dim];
                for (int k = 0; k < patitions; k++) {
                    long key = keys.fetchRow(k).getLong(1);
                    client.callProcedure(new LRCallback(grad), "Solve", key, weights, stepsize);
                }
                //wait all stored procedure finished
                client.drain();

                for (int i =0; i < weights.length; i++) {
                    weights[i] -= grad[i] + 0.5 * lambda * weights[i];
                    System.out.print(weights[i] + "\t");
                }

                System.out.println();
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.exit(-1);
        }

        try {
            client.close();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    };

    static class LRCallback implements ProcedureCallback {
        public LRCallback(double[] grad) {
            this.grad = grad;
        }
        @Override
        public void clientCallback(ClientResponse response) {
            if(response.getStatus() != ClientResponse.SUCCESS) {
                System.err.println(response.getStatusString());
                return;
            }

            VoltTable result = response.getResults()[0];
            result.resetRowPosition();
            int i = 0;
            synchronized (grad) {
                while (result.advanceRow()) {
                    grad[i] += result.getDouble(0);
                    i++;
                }
                //System.out.println("the "+k+" patition");
                //System.out.print(result);
                //System.out.println();
            }
        }

        double[] grad;
    }
}
